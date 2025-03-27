@echo off

:: Backup existing environment variables
if defined ODBCSYSINI (
    set "_CONDA_BACKUP_ODBCSYSINI=%ODBCSYSINI%"
)

if defined ODBCINI (
    set "_CONDA_BACKUP_ODBCINI=%ODBCINI%"
)

:: Set paths to ODBC configuration
set "ODBCSYSINI=%CONDA_PREFIX%\etc"
set "ODBCINI=%CONDA_PREFIX%\etc\odbc.ini"

:: Set variable for driver location
set "MSODBCSQL18_DRIVER_PATH=%CONDA_PREFIX%\Library\bin\msodbcsql18.dll"

:: Backup registry state before modification
set "REG_BACKUP_DIR=%CONDA_PREFIX%\etc\odbc_reg_backup"
if not exist "%REG_BACKUP_DIR%" mkdir "%REG_BACKUP_DIR%"

:: Check if driver already exists in registry and back it up
reg query "HKLM\SOFTWARE\ODBC\ODBCINST.INI\ODBC Drivers" /v "ODBC Driver 18 for SQL Server" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo Backing up existing registry entries...
    reg export "HKLM\SOFTWARE\ODBC\ODBCINST.INI\ODBC Driver 18 for SQL Server" "%REG_BACKUP_DIR%\driver_entry.reg" /y >nul 2>&1
    set "_CONDA_ODBC_DRIVER_EXISTED=1"
) else (
    set "_CONDA_ODBC_DRIVER_EXISTED=0"
)

:: Also check and backup the driver list entry
reg query "HKLM\SOFTWARE\ODBC\ODBCINST.INI\ODBC Drivers" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    reg export "HKLM\SOFTWARE\ODBC\ODBCINST.INI\ODBC Drivers" "%REG_BACKUP_DIR%\drivers_list.reg" /y >nul 2>&1
)

:: Register in Windows registry
set "FULL_PATH=%CONDA_PREFIX:\=\\%"
set "FULL_DRIVER_PATH=%FULL_PATH%\Library\bin\msodbcsql18.dll"

:: pyodbc (and the native Windows ODBC Driver Manager) by default only looks in HKLM:
:: pyodbc.drivers() # reads HKLM\SOFTWARE\ODBC\ODBCINST.INI\ODBC Drivers
:: HKCU is ignored.
:: ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:: Action	                                Where to write?	        Why?
:: Official driver installation	            HKLM	                The driver is available system-wide
:: Temporary registration for the user	    HKCU	                No admin rights needed, but pyodbc won't see it
:: pyodbc must detect the driver	        HKLM	                pyodbc looks there
:: ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
reg add "HKLM\SOFTWARE\ODBC\ODBCINST.INI\ODBC Drivers" /v "ODBC Driver 18 for SQL Server" /t REG_SZ /d "Installed" /f >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    reg add "HKLM\SOFTWARE\ODBC\ODBCINST.INI\ODBC Driver 18 for SQL Server" /v Driver /t REG_SZ /d "%FULL_DRIVER_PATH%" /f >nul 2>&1
    reg add "HKLM\SOFTWARE\ODBC\ODBCINST.INI\ODBC Driver 18 for SQL Server" /v Description /t REG_SZ /d "Microsoft ODBC Driver 18 for SQL Server" /f >nul 2>&1
    reg add "HKLM\SOFTWARE\ODBC\ODBCINST.INI\ODBC Driver 18 for SQL Server" /v Threading /t REG_SZ /d "1" /f >nul 2>&1
    reg add "HKLM\SOFTWARE\ODBC\ODBCINST.INI\ODBC Driver 18 for SQL Server" /v UsageCount /t REG_DWORD /d 1 /f >nul 2>&1
    echo =^> Driver registered in Windows registry (HKLM)
) else (
    echo =^> WARNING: Could not register driver in Windows registry - pyodbc may not see the driver
    echo =^> Driver will still be available via environment configuration
)

echo =^> Environment variables for Microsoft ODBC Driver 18 configured