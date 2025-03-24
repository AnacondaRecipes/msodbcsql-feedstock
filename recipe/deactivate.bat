@echo off

reg delete "HKLM\SOFTWARE\ODBC\ODBCINST.INI\ODBC Driver 18 for SQL Server" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\ODBC\ODBCINST.INI\ODBC Drivers" /v "ODBC Driver 18 for SQL Server" /f >nul 2>&1

:: Restore previous variable values (if they existed)
if defined _CONDA_BACKUP_ODBCSYSINI (
    set "ODBCSYSINI=%_CONDA_BACKUP_ODBCSYSINI%"
    set "_CONDA_BACKUP_ODBCSYSINI="
) else (
    set "ODBCSYSINI="
)

if defined _CONDA_BACKUP_ODBCINI (
    set "ODBCINI=%_CONDA_BACKUP_ODBCINI%"
    set "_CONDA_BACKUP_ODBCINI="
) else (
    set "ODBCINI="
)

:: Unset our custom variables
set "MSODBCSQL18_DRIVER_PATH="
set "ODBCINSTINI="