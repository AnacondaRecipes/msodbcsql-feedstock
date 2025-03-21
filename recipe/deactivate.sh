#!/bin/bash
# conda-helpers/etc/conda/deactivate.d/msodbcsql18.sh
# Deactivation script for restoring ODBC environment variables

# Restore ODBCSYSINI
if [ -n "${_CONDA_BACKUP_ODBCSYSINI+x}" ]; then
    export ODBCSYSINI="$_CONDA_BACKUP_ODBCSYSINI"
    unset _CONDA_BACKUP_ODBCSYSINI
else
    unset ODBCSYSINI
fi

# Restore ODBCINI
if [ -n "${_CONDA_BACKUP_ODBCINI+x}" ]; then
    export ODBCINI="$_CONDA_BACKUP_ODBCINI"
    unset _CONDA_BACKUP_ODBCINI
else
    unset ODBCINI
fi

# Remove driver variable
unset MSODBCSQL18_DRIVER_PATH

echo "==> Environment variables for Microsoft ODBC Driver 18 restored"