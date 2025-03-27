@echo off
setlocal enabledelayedexpansion

:: Check for EULA acceptance
if /I not "%ACCEPT_EULA%"=="Y" if /I not "%ACCEPT_EULA%"=="YES" (
    echo Error: You must accept the EULA to install this package.
    echo The license terms can be viewed at https://aka.ms/odbc18eula
    echo To accept the EULA, set the ACCEPT_EULA environment variable:
    echo     set ACCEPT_EULA=Y
    exit 1
)

:: Create a temporary directory for extracted files
mkdir "%SRC_DIR%\msodbcsql_extract" 2>nul
if errorlevel 1 exit 1

:: Install the MSI in extraction mode to get files without installing
echo Installing ODBC Driver in extraction mode...
msiexec /a "%SRC_DIR%\msodbcsql.msi" /qb TARGETDIR="%SRC_DIR%\msodbcsql_extract"
if errorlevel 1 exit 1

:: Create conda environment directory structure
mkdir "%PREFIX%\Library\include\msodbcsql18"
if errorlevel 1 exit 1
mkdir "%PREFIX%\Library\lib\x86"
if errorlevel 1 exit 1
mkdir "%PREFIX%\Library\lib\x64"
if errorlevel 1 exit 1
mkdir "%PREFIX%\Library\share\doc\msodbcsql18"
if errorlevel 1 exit 1

:: Copy extracted files to conda environment
echo Copying files to conda environment...

:: Copy DLLs to bin directory
copy "%SRC_DIR%\msodbcsql_extract\Windows\System32\msodbcsql18.dll" "%PREFIX%\Library\bin\"
if errorlevel 1 exit 1
copy "%SRC_DIR%\msodbcsql_extract\Windows\System32\msodbcdiag18.dll" "%PREFIX%\Library\bin\"
if errorlevel 1 exit 1
copy "%SRC_DIR%\msodbcsql_extract\Windows\System32\mssql-auth.dll" "%PREFIX%\Library\bin\"
if errorlevel 1 exit 1
copy "%SRC_DIR%\msodbcsql_extract\Windows\System32\1033\msodbcsqlr18.rll" "%PREFIX%\Library\bin\"
if errorlevel 1 exit 1

:: Copy SDK files
copy "%SRC_DIR%\msodbcsql_extract\Program Files\Microsoft SQL Server\Client SDK\ODBC\180\SDK\Include\*" "%PREFIX%\Library\include\msodbcsql18\"
if errorlevel 1 exit 1
copy "%SRC_DIR%\msodbcsql_extract\Program Files\Microsoft SQL Server\Client SDK\ODBC\180\SDK\Lib\x64\*" "%PREFIX%\Library\lib\x64"
if errorlevel 1 exit 1
copy "%SRC_DIR%\msodbcsql_extract\Program Files\Microsoft SQL Server\Client SDK\ODBC\180\SDK\Lib\x86\*" "%PREFIX%\Library\lib\x86"
if errorlevel 1 exit 1

:: Copy documentation
copy "%SRC_DIR%\msodbcsql_extract\Program Files\Microsoft SQL Server\Client SDK\ODBC\180\License Terms\*" "%PREFIX%\Library\share\doc\msodbcsql18\"
if errorlevel 1 exit 1

:: Create odbcinst.ini template file for driver registration
echo Creating ODBC driver registration template...
(
echo [ODBC Driver 18 for SQL Server]
echo Description=Microsoft ODBC Driver 18 for SQL Server
echo Driver=%PREFIX%\Library\bin\msodbcsql18.dll
echo Threading=1
echo UsageCount=1
) > "%PREFIX%\etc\odbcinst.ini.template"
if errorlevel 1 exit 1

:: Create directories for activate/deactivate scripts
mkdir "%PREFIX%\etc\conda\activate.d" 2>nul
mkdir "%PREFIX%\etc\conda\deactivate.d" 2>nul

:: Copy activation/deactivation scripts
copy "%RECIPE_DIR%\activate.bat" "%PREFIX%\etc\conda\activate.d\msodbcsql18.bat"
if errorlevel 1 exit 1
copy "%RECIPE_DIR%\deactivate.bat" "%PREFIX%\etc\conda\deactivate.d\msodbcsql18.bat"
if errorlevel 1 exit 1

:: Clean up
rmdir /s /q "%SRC_DIR%\msodbcsql_extract"
if errorlevel 1 exit 1