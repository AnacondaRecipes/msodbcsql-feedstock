#!/usr/bin/env python
# test_msodbcsql18_windows_pytest.py - pytest tests for msodbcsql18 on Windows
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
import winreg
import pathlib

conda_prefix = None
driver_path = None
etc_dir = None
odbcinst_ini = None
odbc_ini = None

@pytest.fixture(scope="session", autouse=True)
def setup_environment():
    """Setup environment before tests"""
        
    # Get conda prefix
    global conda_prefix, driver_path, etc_dir, odbcinst_ini, odbc_ini
    
    conda_prefix = os.environ.get('CONDA_PREFIX')
    if not conda_prefix:
        conda_prefix = os.environ.get('PREFIX')
        if not conda_prefix:
            pytest.fail("CONDA_PREFIX not set. Run in an activated conda environment.")
        
    # Set platform-specific paths
    driver_path = os.path.join(conda_prefix, 'Library', 'bin', 'msodbcsql18.dll')
    etc_dir = os.path.join(conda_prefix, 'etc')
    
    # Create etc directory if it doesn't exist
    os.makedirs(etc_dir, exist_ok=True)
    
    # Paths to configuration files
    odbcinst_ini = os.path.join(etc_dir, 'odbcinst.ini')
    odbc_ini = os.path.join(etc_dir, 'odbc.ini')
    
    # Create empty odbc.ini for testing if it doesn't exist
    if not os.path.exists(odbc_ini):
        print(f"Creating odbc.ini for testing")
        with open(odbc_ini, 'w') as f:
            f.write("[ODBC Data Sources]\n")

# Tests for driver installation
def test_driver_file_exists():
    print(f"Checking driver file existence: {driver_path}")
    assert os.path.exists(driver_path), f"Driver file not found at path: {driver_path}"

def test_additional_dll_files_exist():
    bin_dir = os.path.dirname(driver_path)
    
    # Check for msodbcdiag18.dll
    msodbcdiag_path = os.path.join(bin_dir, 'msodbcdiag18.dll')
    print(f"Checking msodbcdiag18.dll existence: {msodbcdiag_path}")
    assert os.path.exists(msodbcdiag_path), f"msodbcdiag18.dll not found at path: {msodbcdiag_path}"
    
    # Check for adal.dll
    adal_path = os.path.join(bin_dir, 'adal.dll')
    print(f"Checking adal.dll existence: {adal_path}")
    assert os.path.exists(adal_path), f"adal.dll not found at path: {adal_path}"
    
    # Check for resource file
    resource_path = os.path.join(bin_dir, 'msodbcsqlr18.rll')
    print(f"Checking msodbcsqlr18.rll existence: {resource_path}")
    assert os.path.exists(resource_path), f"msodbcsqlr18.rll not found at path: {resource_path}"

def test_sdk_files_exist():
    include_dir = os.path.join(conda_prefix, 'Library', 'include', 'msodbcsql18')
    lib_x64_dir = os.path.join(conda_prefix, 'Library', 'lib', 'x64')
    lib_x86_dir = os.path.join(conda_prefix, 'Library', 'lib', 'x86')
    
    print(f"Checking include directory: {include_dir}")
    assert os.path.exists(include_dir), f"Include directory not found at path: {include_dir}"
    assert any(os.path.isfile(os.path.join(include_dir, f)) for f in os.listdir(include_dir)), "No files in include directory"
    
    print(f"Checking lib x64 directory: {lib_x64_dir}")
    assert os.path.exists(lib_x64_dir), f"Lib x64 directory not found at path: {lib_x64_dir}"
    assert any(os.path.isfile(os.path.join(lib_x64_dir, f)) for f in os.listdir(lib_x64_dir)), "No files in lib x64 directory"
    
    print(f"Checking lib x86 directory: {lib_x86_dir}")
    assert os.path.exists(lib_x86_dir), f"Lib x86 directory not found at path: {lib_x86_dir}"
    assert any(os.path.isfile(os.path.join(lib_x86_dir, f)) for f in os.listdir(lib_x86_dir)), "No files in lib x86 directory"

def test_odbcinst_ini_exists():
    print(f"Checking odbcinst.ini existence: {odbcinst_ini}")
    assert os.path.exists(odbcinst_ini), f"odbcinst.ini file not found at path: {odbcinst_ini}"

def test_odbc_ini_exists():
    print(f"Checking odbc.ini existence: {odbc_ini}")
    assert os.path.exists(odbc_ini), f"odbc.ini file not found at path: {odbc_ini}"

def test_driver_registered_in_odbcinst_ini():
    print(f"Checking odbcinst.ini contents")
    with open(odbcinst_ini, 'r') as f:
        content = f.read()
    
    assert "[ODBC Driver 18 for SQL Server]" in content, "Driver is not registered in odbcinst.ini"
    
    # Check that driver path is correctly specified
    assert "Driver=" in content, "Missing 'Driver=' line in odbcinst.ini"
    assert "msodbcsql18.dll" in content, "Incorrect driver path in odbcinst.ini"

def test_environment_variables_set():
    """Test that environment variables are set"""
    print("Checking environment variables")
    
    print("ODBCSYSINI — the location for the system-wide odbc.ini and odbcinst.ini files.")
    odbcsysini = os.environ.get('ODBCSYSINI')
    print(f"ODBCSYSINI = {odbcsysini or 'not set'}")
    
    print("ODBCINI — the full path to the user-specific odbc.ini file if you want to specify a particular file.")
    odbcini = os.environ.get('ODBCINI')
    print(f"ODBCINI = {odbcini or 'not set'}")

    odbcinstini = os.environ.get('ODBCINSTINI')
    print(f"ODBCINSTINI = {odbcinstini or 'not set'}")
    
    # Verify they're set now (either originally or by us)
    assert os.environ.get('ODBCSYSINI') is not None, "ODBCSYSINI could not be set"
    assert os.environ.get('ODBCINI') is not None, "ODBCINI could not be set"

def test_windows_registry_entries():
    print("Checking Windows registry entries")

    try:
        print("Checking HKLM registry entries")
        with winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, r'SOFTWARE\ODBC\ODBCINST.INI\ODBC Drivers') as key:
            driver_value = winreg.QueryValueEx(key, 'ODBC Driver 18 for SQL Server')[0]
            assert driver_value == 'Installed', "Driver not marked as installed in HKLM registry"
            print("Driver registered in HKLM registry")
        
        with winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, r'SOFTWARE\ODBC\ODBCINST.INI\ODBC Driver 18 for SQL Server') as key:
            driver_path_value = winreg.QueryValueEx(key, 'Driver')[0]
            assert 'msodbcsql18.dll' in driver_path_value, "Incorrect driver path in HKLM registry"
            print(f"Driver path in HKLM registry: {driver_path_value}")
        
        return  # HKLM entries are valid
    except (FileNotFoundError, WindowsError):
        pytest.fail("Driver not registered in HKLM registry")
    
    pytest.fail("Driver not registered in Windows registry")

# Create a pytest fixture to provide pyodbc module
@pytest.fixture
def pyodbc_module():
    """Fixture to provide pyodbc module"""
    try:
        import pyodbc
        return pyodbc
    except ImportError:
        print("pyodbc is not installed. Installing temporary version for testing...")
        return None

def test_connection_with_pyodbc(pyodbc_module):
    print("Testing ODBC driver loading")
    
    # List available ODBC drivers from pyodbc
    drivers = pyodbc_module.drivers()
    print(f"Available ODBC drivers: {drivers}")
    
    # Target driver to check
    target_driver = "ODBC Driver 18 for SQL Server"
    
    # Check if the driver is in pyodbc drivers list
    if target_driver in drivers:
        print(f"Driver '{target_driver}' successfully registered with pyodbc")
    else:
        pytest.fail(f"Driver '{target_driver}' not found in pyodbc drivers list")

# This test works only locally. We can`t use docker in the tests or setup for example SQL Server Express
# To check connection to the sql server with ODBC Driver you must:
# 1) docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=YourStrong@Passw0rd" -e "MSSQL_PID=Developer" -e "MSSQL_TCP_PORT=1433" -p 1433:1433 --name sql-server-container --memory 2g --cpus 2 -d mcr.microsoft.com/mssql/server:2022-latest
# 2) run test if previous commands work well.
# +++++++++++++++++++++++++++++++++++
# 3) docker stop sql-server-container
# 4) docker rm sql-server-container

def test_ms_odbc_connection(pyodbc_module):
    """Test connecting to SQL Server via ODBC"""
    print("Testing connection to SQL Server using MS ODBC driver")

    server = '127.0.0.1,1433'
    database = 'master'
    username = 'sa'
    password = 'YourStrong@Passw0rd'
    driver = 'ODBC Driver 18 for SQL Server'
    
    conn_str = f'DRIVER={{{driver}}};SERVER={server};DATABASE={database};UID={username};PWD={password};TrustServerCertificate=yes;'

    print(f"Using connection string: {conn_str}")
    
    try:
        conn = pyodbc_module.connect(conn_str)
        cursor = conn.cursor()
        
        cursor.execute("SELECT @@VERSION")
        version = cursor.fetchone()[0]
        print(f"SQL Server version: {version}")
        
        conn.close()
        print("SQL Server connection test passed")
        return True
    except pyodbc_module.Error as e:
        error_msg = str(e).lower()
        print(f"Connection error: {error_msg}")
        assert(False)

