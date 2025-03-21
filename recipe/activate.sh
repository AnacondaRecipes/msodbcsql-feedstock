#!/bin/bash
# conda-helpers/etc/conda/activate.d/msodbcsql18.sh
# Activation script for setting ODBC environment variables

# Save current variable values (if they exist)
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

# Create ODBC configuration during activation
mkdir -p "$CONDA_PREFIX/etc"

# Create odbcinst.ini if it doesn't exist
if [ ! -f "$CONDA_PREFIX/etc/odbcinst.ini" ]; then
    echo "[ODBC Driver 18 for SQL Server]" > "$CONDA_PREFIX/etc/odbcinst.ini"
    echo "Description=Microsoft ODBC Driver 18 for SQL Server" >> "$CONDA_PREFIX/etc/odbcinst.ini"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "Driver=$CONDA_PREFIX/lib/libmsodbcsql.18.dylib" >> "$CONDA_PREFIX/etc/odbcinst.ini"
    elif [[ "$OSTYPE" == "linux"* ]]; then
        echo "Driver=$CONDA_PREFIX/lib/libmsodbcsql-18.4.so.1.1" >> "$CONDA_PREFIX/etc/odbcinst.ini"
    fi
    echo "UsageCount=1" >> "$CONDA_PREFIX/etc/odbcinst.ini"
fi

# Create empty odbc.ini if it doesn't exist
if [ ! -f "$CONDA_PREFIX/etc/odbc.ini" ]; then
    echo "[ODBC Data Sources]" > "$CONDA_PREFIX/etc/odbc.ini"
    echo "# Add your data sources here" >> "$CONDA_PREFIX/etc/odbc.ini"
fi

echo "==> Environment variables for Microsoft ODBC Driver 18 configured"