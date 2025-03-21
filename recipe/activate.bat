@echo off
:: conda-helpers\etc\conda\activate.d\msodbcsql18.bat
:: Activation script for setting up ODBC environment variables on Windows

:: Save current variable values (if they exist)
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
    echo Driver=%CONDA_PREFIX%\Library\bin\msodbcsql18.dll >> "%CONDA_PREFIX%\etc\odbcinst.ini"
    echo Threading=1 >> "%CONDA_PREFIX%\etc\odbcinst.ini"
    echo UsageCount=1 >> "%CONDA_PREFIX%\etc\odbcinst.ini"
)

:: Create empty odbc.ini if it doesn't exist
if not exist "%CONDA_PREFIX%\etc\odbc.ini" (
    echo [ODBC Data Sources] > "%CONDA_PREFIX%\etc\odbc.ini"
    echo # Add your data sources here >> "%CONDA_PREFIX%\etc\odbc.ini"
)

:: echo =^> Environment variables for Microsoft ODBC Driver 18 configured