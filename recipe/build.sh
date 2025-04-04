#!/bin/bash

set -ex

MAJOR_VERSION=$(echo $PKG_VERSION | cut -d. -f1)
MINOR_VERSION=$(echo $PKG_VERSION | cut -d. -f2)
PATCH_VERSION=$(echo $PKG_VERSION | cut -d. -f3)
SUBPATCH_VERSION=$(echo $PKG_VERSION | cut -d. -f4)

# For library paths
MAJOR_MINOR="${MAJOR_VERSION}.${MINOR_VERSION}"

# Check for EULA acceptance
if [[ "$ACCEPT_EULA" != "Y" && "$ACCEPT_EULA" != "y" ]]; then
    echo "Error: You must accept the EULA to install this package."
    echo "The license terms can be viewed at https://aka.ms/odbc${MAJOR_VERSION}eula"
    echo "To accept the EULA, set the ACCEPT_EULA environment variable:"
    echo "    ACCEPT_EULA=Y conda build <recipe-dir>"
    exit 1
fi

# Create directory for configuration
mkdir -p $PREFIX/etc
mkdir -p $PREFIX/lib
mkdir -p $PREFIX/share/msodbcsql${MAJOR_VERSION}/resources/en_US
mkdir -p $PREFIX/share/resources/en_US
mkdir -p $PREFIX/include/msodbcsql${MAJOR_VERSION}
mkdir -p $PREFIX/share/doc/msodbcsql${MAJOR_VERSION}

if [[ ${target_platform} == osx-* ]]; then
    # Install the main library file
    cp -p lib/libmsodbcsql.${MAJOR_VERSION}.dylib $PREFIX/lib/
    # Install resource files
    cp -p share/msodbcsql${MAJOR_VERSION}/resources/en_US/msodbcsqlr${MAJOR_VERSION}.rll $PREFIX/share/msodbcsql${MAJOR_VERSION}/resources/en_US/
    cp -p share/msodbcsql${MAJOR_VERSION}/resources/en_US/msodbcsqlr${MAJOR_VERSION}.rll $PREFIX/share/resources/en_US/
    # Install header files
    cp -p include/msodbcsql${MAJOR_VERSION}/msodbcsql.h $PREFIX/include/msodbcsql${MAJOR_VERSION}/
    # Install documentation
    cp -p share/doc/msodbcsql${MAJOR_VERSION}/LICENSE.txt $PREFIX/share/doc/msodbcsql${MAJOR_VERSION}/
    cp -p share/doc/msodbcsql${MAJOR_VERSION}/RELEASE_NOTES $PREFIX/share/doc/msodbcsql${MAJOR_VERSION}/

    # Create odbcinst.ini template for use during activation
    cat > $PREFIX/etc/odbcinst.ini << EOF
[ODBC Driver ${MAJOR_VERSION} for SQL Server]
Description=Microsoft ODBC Driver ${MAJOR_VERSION} for SQL Server
Driver=$PREFIX/lib/libmsodbcsql.${MAJOR_VERSION}.dylib
UsageCount=1
EOF

elif [[ ${target_platform} == linux-* ]]; then
    # For Linux, extract the .deb package
    mkdir -p tmp_extract
    tar -xf data.tar.xz -C tmp_extract
    # Install the main library file
    cp -p tmp_extract/opt/microsoft/msodbcsql${MAJOR_VERSION}/lib64/libmsodbcsql-${MAJOR_MINOR}.so.${PATCH_VERSION}.${SUBPATCH_VERSION} $PREFIX/lib/
    # Create symbolic link
    ln -sf $PREFIX/lib/libmsodbcsql-${MAJOR_MINOR}.so.${PATCH_VERSION}.${SUBPATCH_VERSION} $PREFIX/lib/libmsodbcsql-${MAJOR_VERSION}.so
    # Install resource files
    cp -p tmp_extract/opt/microsoft/msodbcsql${MAJOR_VERSION}/share/resources/en_US/msodbcsqlr${MAJOR_VERSION}.rll $PREFIX/share/msodbcsql${MAJOR_VERSION}/resources/en_US/
    cp -p tmp_extract/opt/microsoft/msodbcsql${MAJOR_VERSION}/share/resources/en_US/msodbcsqlr${MAJOR_VERSION}.rll $PREFIX/share/resources/en_US/
    # Install header files
    cp -p tmp_extract/opt/microsoft/msodbcsql${MAJOR_VERSION}/include/msodbcsql.h $PREFIX/include/msodbcsql${MAJOR_VERSION}/
    # Install documentation
    cp -p tmp_extract/usr/share/doc/msodbcsql${MAJOR_VERSION}/LICENSE.txt $PREFIX/share/doc/msodbcsql${MAJOR_VERSION}/

    # Create odbcinst.ini for use during activation
    cat > $PREFIX/etc/odbcinst.ini << EOF
[ODBC Driver ${MAJOR_VERSION} for SQL Server]
Description=Microsoft ODBC Driver ${MAJOR_VERSION} for SQL Server
Driver=$PREFIX/lib/libmsodbcsql-${MAJOR_MINOR}.so.${PATCH_VERSION}.${SUBPATCH_VERSION}
UsageCount=1
EOF

fi

# Create odbc.ini template for use during activation
cat > $PREFIX/etc/odbc.ini << EOF
[ODBC Data Sources]
# Add your data sources here
EOF

# Copy license to standard location
mkdir -p $PREFIX/share/licenses/$PKG_NAME
cp $PREFIX/share/doc/msodbcsql${MAJOR_VERSION}/LICENSE.txt $PREFIX/share/licenses/$PKG_NAME/

# Create directories for activate/deactivate scripts
mkdir -p $PREFIX/etc/conda/activate.d
mkdir -p $PREFIX/etc/conda/deactivate.d

# Copy scripts from recipe
cp $RECIPE_DIR/activate.sh $PREFIX/etc/conda/activate.d/msodbcsql${MAJOR_VERSION}.sh
cp $RECIPE_DIR/deactivate.sh $PREFIX/etc/conda/deactivate.d/msodbcsql${MAJOR_VERSION}.sh

# Make scripts executable
chmod +x $PREFIX/etc/conda/activate.d/msodbcsql${MAJOR_VERSION}.sh
chmod +x $PREFIX/etc/conda/deactivate.d/msodbcsql${MAJOR_VERSION}.sh