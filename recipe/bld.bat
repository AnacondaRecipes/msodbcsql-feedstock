@echo off
setlocal enabledelayedexpansion

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
copy "%SRC_DIR%\msodbcsql_extract\Windows\System32\adal.dll" "%PREFIX%\Library\bin\"
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
) > "%PREFIX%\odbcinst.ini"
if errorlevel 1 exit 1

:: Clean up
rmdir /s /q "%TEMP%\msodbcsql_extract"
if errorlevel 1 exit 1
