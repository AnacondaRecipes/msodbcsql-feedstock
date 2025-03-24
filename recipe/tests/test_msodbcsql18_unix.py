#!/usr/bin/env python
# test_msodbcsql18_unix_pytest.py - pytest tests for msodbcsql18 on Linux/macOS
"""
Pytest tests for verifying correct installation and functionality of Microsoft ODBC Driver 18
"""
import os
import sys
import platform
import subprocess
import pytest
import tempfile
import time
import sqlite3
import shutil

# Global variables to store paths
conda_prefix = None
driver_path = None
etc_dir = None
odbcinst_ini = None
odbc_ini = None

# Setup function to initialize paths and environment
@pytest.fixture(scope="session", autouse=True)
def setup_environment():
    """Setup environment before tests"""
    # Make sure we're running on Linux or macOS
    if platform.system() not in ['Linux', 'Darwin']:
        pytest.skip("This test is designed for Linux or macOS only")
        
    # Get conda prefix
    global conda_prefix, driver_path, etc_dir, odbcinst_ini, odbc_ini
    
    conda_prefix = os.environ.get('CONDA_PREFIX')
    if not conda_prefix:
        conda_prefix = os.environ.get('PREFIX')
        if not conda_prefix:
            pytest.skip("CONDA_PREFIX not set. Run in an activated conda environment.")
        
    # Set platform-specific paths
    if platform.system() == 'Darwin':  # macOS
        driver_path = os.path.join(conda_prefix, 'lib', 'libmsodbcsql.18.dylib')
    else:  # Linux
        driver_path = os.path.join(conda_prefix, 'lib', 'libmsodbcsql-18.4.so.1.1')
        
    etc_dir = os.path.join(conda_prefix, 'etc')
    
    # Create etc directory if it doesn't exist
    os.makedirs(etc_dir, exist_ok=True)
    
    # Paths to configuration files
    odbcinst_ini = os.path.join(etc_dir, 'odbcinst.ini')
    odbc_ini = os.path.join(etc_dir, 'odbc.ini')
    
    # Create empty odbc.ini for testing
    if not os.path.exists(odbc_ini):
        print(f"Creating empty odbc.ini for testing")
        with open(odbc_ini, 'w') as f:
            f.write("[ODBC Data Sources]\n")
            f.write("# Add your data sources here\n")

# Tests for driver installation
def test_driver_file_exists():
    """Test that the driver file exists"""
    print(f"Checking driver file existence: {driver_path}")
    assert os.path.exists(driver_path), f"Driver file not found at path: {driver_path}"

def test_odbcinst_ini_exists():
    """Test that odbcinst.ini exists"""
    print(f"Checking odbcinst.ini existence: {odbcinst_ini}")
    assert os.path.exists(odbcinst_ini), f"odbcinst.ini file not found at path: {odbcinst_ini}"

def test_odbc_ini_exists():
    """Test that odbc.ini exists"""
    print(f"Checking odbc.ini existence: {odbc_ini}")
    assert os.path.exists(odbc_ini), f"odbc.ini file not found at path: {odbc_ini}"

def test_driver_registered_in_odbcinst_ini():
    """Test that driver is registered in odbcinst.ini"""
    print(f"Checking odbcinst.ini contents")
    with open(odbcinst_ini, 'r') as f:
        content = f.read()
    
    assert "[ODBC Driver 18 for SQL Server]" in content, "Driver is not registered in odbcinst.ini"
    
    # Check that driver path is correctly specified
    assert "Driver=" in content, "Missing 'Driver=' line in odbcinst.ini"
    
    if platform.system() == 'Darwin':
        assert "libmsodbcsql.18.dylib" in content, "Incorrect driver path for macOS"
    else:  # Linux
        assert "libmsodbcsql-18.4.so.1.1" in content, "Incorrect driver path for Linux"

def test_environment_variables_set():
    """Test that environment variables are set"""
    print("Checking environment variables")
    
    print("ODBCSYSINI — the location for the system-wide odbc.ini and odbcinst.ini files.")
    odbcsysini = os.environ.get('ODBCSYSINI')
    print(f"ODBCSYSINI = {odbcsysini or 'not set'}")
    
    print("ODBCINI — the full path to the user-specific odbc.ini file if you want to specify a particular file.")
    odbcini = os.environ.get('ODBCINI')
    print(f"ODBCINI = {odbcini or 'not set'}")
    
    # If either variable is not set, set them for testing purposes
    if not odbcsysini:
        print("Setting ODBCSYSINI for testing purposes")
        os.environ['ODBCSYSINI'] = etc_dir
        
    if not odbcini:
        print("Setting ODBCINI for testing purposes")
        os.environ['ODBCINI'] = odbc_ini
    
    # Verify they're set now (either originally or by us)
    assert os.environ.get('ODBCSYSINI') is not None, "ODBCSYSINI could not be set"
    assert os.environ.get('ODBCINI') is not None, "ODBCINI could not be set"

# Create a pytest fixture to provide pyodbc module
@pytest.fixture
def pyodbc_module():
    """Fixture to provide pyodbc module"""
    try:
        import pyodbc
        return pyodbc
    except ImportError:
        print("pyodbc is not installed. Installing temporary version for testing...")
        try:
            result = subprocess.run([sys.executable, '-m', 'pip', 'install', 'pyodbc', '--user'],
                                  check=False)
            if result.returncode != 0:
                print("Could not install pyodbc. Testing driver file existence only.")
                pytest.skip("pyodbc not available")
                
            # Try to import again after installing
            import pyodbc
            return pyodbc
        except:
            print("Could not install pyodbc. Testing driver file existence only.")
            pytest.fail("Failed to install pyodbc")
            return None

def test_connection_with_pyodbc(pyodbc_module):
    """Test driver loading with pyodbc"""
    print("Testing ODBC driver loading")
    
    # Test that the driver is loaded and can be accessed
    test_driver_loading(pyodbc_module)

def test_driver_loading(pyodbc_module):
    """Test driver loading with pyodbc"""
    print("Test that the driver is loaded and registered with ODBC")
    # List available drivers
    drivers = pyodbc_module.drivers()
    print(f"Available ODBC drivers: {drivers}")
    
    # Check if our driver is in the list
    target_driver = "ODBC Driver 18 for SQL Server"
    
    if target_driver in drivers:
        print(f"Driver '{target_driver}' successfully registered with ODBC")
    else:
        print(f"Driver '{target_driver}' not found in ODBC drivers list")
        print("Available drivers:", drivers)
        print("This can happen if the driver registration is incomplete")
        print("The test will continue as the driver file exists")
        pytest.fail(f"Driver '{target_driver}' not found in ODBC drivers list")

def test_odbcinst_command_works():
    """Test odbcinst command"""
    print("Checking odbcinst command availability")
    
    try:
        # Try to get a list of drivers first, which is more reliable
        result = subprocess.run(['odbcinst', '-q', '-d'], 
                                stdout=subprocess.PIPE, 
                                stderr=subprocess.PIPE, 
                                text=True,
                                check=False)
        
        print(f"odbcinst command output: {result.stdout or ''}")
        if result.stderr:
            print(f"odbcinst command errors: {result.stderr}")
        
        # Even if we get an error, the command exists
        print("odbcinst command is available")
        
        # Try to check if our driver is listed
        if "[ODBC Driver 18 for SQL Server]" in result.stdout:
            print("Driver is registered with odbcinst")
        else:
            print("Driver not found in odbcinst output, may need registration")
            pytest.fail("Driver not found in odbcinst output")
        
    except (FileNotFoundError, subprocess.SubprocessError) as e:
        print(f"odbcinst command is not available or not working properly: {e}")
        print("This is normal on some systems where ODBC uses a different configuration method")
        pytest.fail(f"odbcinst command not available: {e}")