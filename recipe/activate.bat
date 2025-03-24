@echo off

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

:: Create configuration directory
if not exist "%CONDA_PREFIX%\etc" (
    mkdir "%CONDA_PREFIX%\etc"
)

:: Create odbcinst.ini if it doesn't exist
if not exist "%CONDA_PREFIX%\etc\odbcinst.ini" (
    echo [ODBC Driver 18 for SQL Server] > "%CONDA_PREFIX%\etc\odbcinst.ini"
    echo Description=Microsoft ODBC Driver 18 for SQL Server >> "%CONDA_PREFIX%\etc\odbcinst.ini"
    echo Driver=%MSODBCSQL18_DRIVER_PATH% >> "%CONDA_PREFIX%\etc\odbcinst.ini"
    echo Threading=1 >> "%CONDA_PREFIX%\etc\odbcinst.ini"
    echo UsageCount=1 >> "%CONDA_PREFIX%\etc\odbcinst.ini"
)

:: Create empty odbc.ini if it doesn't exist
if not exist "%CONDA_PREFIX%\etc\odbc.ini" (
    echo [ODBC Data Sources] > "%CONDA_PREFIX%\etc\odbc.ini"
    echo # Add your data sources here >> "%CONDA_PREFIX%\etc\odbc.ini"
)

:: Register in Windows registry - CRITICAL for pyodbc to find the driver
:: Expand %CONDA_PREFIX% to the full path before adding to the registry
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