#!/bin/bash

set -ex

# ODBCSYSINI specifies where to find ODBC configuration files, such as odbc.ini and odbcinst.ini.
echo 'export ODBCSYSINI=$CONDA_PREFIX/lib/msodbcsql18' >> ~/miniconda3/envs/dev-env/etc/activate.sh

# Need to change path to the driver in odbcinst.ini
sed -i '' 's|^Driver=.*|Driver='"$CONDA_PREFIX/lib/msodbcsql18/lib/libmsodbcsql.18.dylib"'|' "$CONDA_PREFIX/lib/msodbcsql18/odbcinst.ini"
