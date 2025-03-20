#!/bin/bash
# post-link.sh - Register the driver with unixODBC and create symlinks if needed

set -e

DRIVER_PATH="${PREFIX}/lib/libmsodbcsql.18.dylib"
DRIVER_NAME="ODBC Driver 18 for SQL Server"
# Unregister any existing driver with the same name
"${PREFIX}/bin/odbcinst" -u -d -n "${DRIVER_NAME}" > /dev/null 2>&1 || true
#sed -i '' 's|^Driver=.*|Driver='"/Users/aosipo/miniconda3/conda-bld/msodbcsql18_1742501215744/work_moved_msodbcsql18-18.4.1.1-h9e2d7d8_5_osx-arm64/lib/libmsodbcsql.18.dylib"'|' "$PREFIX/odbcinst.ini"
# Register the driver
#cat ${PREFIX}/odbcinst.ini
"${PREFIX}/bin/odbcinst" -i -d -f "${PREFIX}/odbcinst.ini" -v
# Create symlinks in system directories if running with sufficient privileges
# This helps applications find the driver when not using the conda environment paths
if [ -w /etc ]; then
    # Create symlinks for odbcinst.ini and odbc.ini if they don't exist
    # This helps with common connection issues
    if [ ! -e /etc/odbcinst.ini ]; then
        ln -sf "${PREFIX}/etc/odbcinst.ini" /etc/odbcinst.ini
    fi
    if [ ! -e /etc/odbc.ini ]; then
        ln -sf "${PREFIX}/etc/odbc.ini" /etc/odbc.ini
    fi
fi
echo 6666666

# Print installation message
echo "Microsoft ODBC Driver 18 for SQL Server has been installed and registered with unixODBC." >> $PREFIX/.messages.txt
echo "" >> $PREFIX/.messages.txt
echo "Note: If you experience connection issues like '[01000] [unixODBC][Driver Manager]Can't open lib'," >> $PREFIX/.messages.txt
echo "you may need to create system-wide symbolic links with:" >> $PREFIX/.messages.txt
echo "    sudo ln -s $PREFIX/etc/odbcinst.ini /etc/odbcinst.ini" >> $PREFIX/.messages.txt
echo "    sudo ln -s $PREFIX/etc/odbc.ini /etc/odbc.ini" >> $PREFIX/.messages.txt
echo "" >> $PREFIX/.messages.txt
echo "If you uninstall this package, you'll need to manually remove the driver" >> $PREFIX/.messages.txt
echo "registration by executing:" >> $PREFIX/.messages.txt
echo "    odbcinst -u -d -n \"ODBC Driver 18 for SQL Server\"" >> $PREFIX/.messages.txt