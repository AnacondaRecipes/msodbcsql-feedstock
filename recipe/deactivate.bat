@echo off

:: Check if we need to restore or delete registry entries
set "REG_BACKUP_DIR=%CONDA_PREFIX%\etc\odbc_reg_backup"

if defined _CONDA_ODBC_DRIVER_EXISTED (
    if %_CONDA_ODBC_DRIVER_EXISTED% EQU 1 (
        echo Restoring original registry entries...
        if exist "%REG_BACKUP_DIR%\driver_entry.reg" (
            reg import "%REG_BACKUP_DIR%\driver_entry.reg" >nul 2>&1
        )
        if exist "%REG_BACKUP_DIR%\drivers_list.reg" (
            reg import "%REG_BACKUP_DIR%\drivers_list.reg" >nul 2>&1
        )
    ) else (
        echo Removing added registry entries...
        reg delete "HKLM\SOFTWARE\ODBC\ODBCINST.INI\ODBC Driver 18 for SQL Server" /f >nul 2>&1
        reg delete "HKLM\SOFTWARE\ODBC\ODBCINST.INI\ODBC Drivers" /v "ODBC Driver 18 for SQL Server" /f >nul 2>&1
    )
    set "_CONDA_ODBC_DRIVER_EXISTED="
) else (
    echo WARNING: Registry state could not be determined, performing standard cleanup...
    reg delete "HKLM\SOFTWARE\ODBC\ODBCINST.INI\ODBC Driver 18 for SQL Server" /f >nul 2>&1
    reg delete "HKLM\SOFTWARE\ODBC\ODBCINST.INI\ODBC Drivers" /v "ODBC Driver 18 for SQL Server" /f >nul 2>&1
)

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
echo =^> ODBC configuration restored to original state