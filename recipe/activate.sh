#!/bin/bash

MAJOR_VERSION=$(echo $PKG_VERSION | cut -d. -f1)
MINOR_VERSION=$(echo $PKG_VERSION | cut -d. -f2)
PATCH_VERSION=$(echo $PKG_VERSION | cut -d. -f3)
SUBPATCH_VERSION=$(echo $PKG_VERSION | cut -d. -f4)

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
    export MSODBCSQL${MAJOR_VERSION}_DRIVER_PATH="$CONDA_PREFIX/lib/libmsodbcsql.${MAJOR_VERSION}.dylib"
elif [[ "$OSTYPE" == "linux"* ]]; then
    export MSODBCSQL${MAJOR_VERSION}_DRIVER_PATH="$CONDA_PREFIX/lib/libmsodbcsql-${MAJOR_VERSION}.${MINOR_VERSION}.so.${PATCH_VERSION}.${SUBPATCH_VERSION}"
fi

echo "==> Environment variables for Microsoft ODBC Driver ${MAJOR_VERSION} configured"