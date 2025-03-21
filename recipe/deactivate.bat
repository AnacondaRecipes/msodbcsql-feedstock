@echo off
:: conda-helpers\etc\conda\deactivate.d\msodbcsql18.bat
:: Deactivation script for restoring ODBC environment variables on Windows

:: Restore ODBCSYSINI
if defined _CONDA_BACKUP_ODBCSYSINI (
    set "ODBCSYSINI=%_CONDA_BACKUP_ODBCSYSINI%"
    set "_CONDA_BACKUP_ODBCSYSINI="
) else (
    set "ODBCSYSINI="
)

:: Restore ODBCINI
if defined _CONDA_BACKUP_ODBCINI (
    set "ODBCINI=%_CONDA_BACKUP_ODBCINI%"
    set "_CONDA_BACKUP_ODBCINI="
) else (
    set "ODBCINI="
)

:: Remove driver variable
set "MSODBCSQL18_DRIVER_PATH="

::echo =^> Environment variables for Microsoft ODBC Driver 18 restored