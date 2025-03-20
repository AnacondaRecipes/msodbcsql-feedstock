@echo on

msiexec /a "%SRC_DIR%\msodbcsql.msi" /qb TARGETDIR="%SRC_DIR%\tmp"
if errorlevel 1 exit 1

copy "%SRC_DIR%\tmp\Windows\System32\msodbcsql18.dll" %PREFIX%\Library\bin
copy "%SRC_DIR%\tmp\Windows\System32\msodbcdiag18.dll" %PREFIX%\Library\bin
copy "%SRC_DIR%\tmp\Windows\System32\adal.dll" %PREFIX%\Library\bin

copy "%SRC_DIR%\tmp\Program Files\Microsoft SQL Server\Client SDK\ODBC\180\SDK\Include\msodbcsql.h" %PREFIX%\Library\include
copy "%SRC_DIR%\tmp\Program Files\Microsoft SQL Server\Client SDK\ODBC\180\SDK\Lib\x64\msodbcsql18.lib" %PREFIX%\Library\lib
if errorlevel 1 exit 1
