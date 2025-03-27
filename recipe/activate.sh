#!/bin/bash

if [ -n "${ODBCSYSINI+x}" ]; then
    export _CONDA_BACKUP_ODBCSYSINI="$ODBCSYSINI"
fi

if [ -n "${ODBCINI+x}" ]; then
    export _CONDA_BACKUP_ODBCINI="$ODBCINI"
fi

# Set paths to ODBC configuration
export ODBCSYSINI="$CONDA_PREFIX/etc"
export ODBCINI="$CONDA_PREFIX/etc/odbc.ini"

# Add driver path to PATH (if needed)
if [[ ":$PATH:" != *":$CONDA_PREFIX/lib:"* ]]; then
    export PATH="$CONDA_PREFIX/lib:$PATH"
fi

# Set variable for driver location
if [[ "$OSTYPE" == "darwin"* ]]; then
    export MSODBCSQL18_DRIVER_PATH="$CONDA_PREFIX/lib/libmsodbcsql.18.dylib"
elif [[ "$OSTYPE" == "linux"* ]]; then
    export MSODBCSQL18_DRIVER_PATH="$CONDA_PREFIX/lib/libmsodbcsql-18.4.so.1.1"
fi

echo "==> Environment variables for Microsoft ODBC Driver 18 configured"