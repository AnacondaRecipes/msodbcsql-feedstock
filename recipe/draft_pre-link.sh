#!/bin/bash
# pre-unlink.sh - Unregister driver when package is removed

set -e

# Skip on non-existent odbcinst (happens during environment deactivation)
if [ ! -f "${PREFIX}/bin/odbcinst" ]; then
    exit 0
fi

# Attempt to unregister the driver
"${PREFIX}/bin/odbcinst" -u -d -n "ODBC Driver 18 for SQL Server" || \
    echo "Warning: Failed to unregister ODBC Driver 18 for SQL Server" >> $PREFIX/.messages.txt

# Check if we've created any symlinks and remove them if possible
if [ -L /etc/odbcinst.ini ] && [ "$(readlink /etc/odbcinst.ini)" == "${PREFIX}/etc/odbcinst.ini" ]; then
    if [ -w /etc/odbcinst.ini ]; then
        rm -f /etc/odbcinst.ini
    else
        echo "Warning: Symlink at /etc/odbcinst.ini may need to be manually removed" >> $PREFIX/.messages.txt
    fi
fi

if [ -L /etc/odbc.ini ] && [ "$(readlink /etc/odbc.ini)" == "${PREFIX}/etc/odbc.ini" ]; then
    if [ -w /etc/odbc.ini ]; then
        rm -f /etc/odbc.ini
    else
        echo "Warning: Symlink at /etc/odbc.ini may need to be manually removed" >> $PREFIX/.messages.txt
    fi
fi