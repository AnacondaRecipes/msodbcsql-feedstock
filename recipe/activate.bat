@echo off

for /f "tokens=1 delims=." %%a in ("%PKG_VERSION%") do (
    set MAJOR_VERSION=%%a
)

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
set "MSODBCSQL%MAJOR_VERSION%_DRIVER_PATH=%CONDA_PREFIX%\Library\bin\msodbcsql%MAJOR_VERSION%.dll"

echo ====================================================================
echo IMPORTANT: Manual ODBC Driver Registration Required
echo ====================================================================
echo.
echo The ODBC Driver %MAJOR_VERSION% for SQL Server needs to be registered
echo in the Windows registry for applications like pyodbc to detect it.
echo.
echo Please follow these steps to register the driver manually:
echo.
echo 1. Open an Administrator Command Prompt
echo 2. Run the following commands:
echo.
echo    reg add "HKLM\SOFTWARE\ODBC\ODBCINST.INI\ODBC Drivers" /v "ODBC Driver %MAJOR_VERSION% for SQL Server" /t REG_SZ /d "Installed" /f
echo    reg add "HKLM\SOFTWARE\ODBC\ODBCINST.INI\ODBC Driver %MAJOR_VERSION% for SQL Server" /v Driver /t REG_SZ /d "%CONDA_PREFIX%\Library\bin\msodbcsql%MAJOR_VERSION%.dll" /f
echo    reg add "HKLM\SOFTWARE\ODBC\ODBCINST.INI\ODBC Driver %MAJOR_VERSION% for SQL Server" /v Description /t REG_SZ /d "Microsoft ODBC Driver %MAJOR_VERSION% for SQL Server" /f
echo    reg add "HKLM\SOFTWARE\ODBC\ODBCINST.INI\ODBC Driver %MAJOR_VERSION% for SQL Server" /v Threading /t REG_SZ /d "1" /f
echo    reg add "HKLM\SOFTWARE\ODBC\ODBCINST.INI\ODBC Driver %MAJOR_VERSION% for SQL Server" /v UsageCount /t REG_DWORD /d 1 /f
echo.
echo Alternatively, you can use the odbcconf utility:
echo    odbcconf /a {CONFIGDRIVER "ODBC Driver %MAJOR_VERSION% for SQL Server" INSTALL "Microsoft ODBC Driver %MAJOR_VERSION% for SQL Server" "%CONDA_PREFIX%\Library\bin\msodbcsql%MAJOR_VERSION%.dll"}
echo.
echo NOTE: Environment variables for ODBC configuration have been set,
echo but pyodbc and other applications may still require HKLM registry registration.
echo ====================================================================

echo =^> Environment variables for Microsoft ODBC Driver %MAJOR_VERSION% configured