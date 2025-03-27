#!/bin/bash

set -ex

# Check for EULA acceptance
if [[ "$ACCEPT_EULA" != "Y" && "$ACCEPT_EULA" != "y" ]]; then
    echo "Error: You must accept the EULA to install this package."
    echo "The license terms can be viewed at https://aka.ms/odbc18eula"
    echo "To accept the EULA, set the ACCEPT_EULA environment variable:"
    echo "    ACCEPT_EULA=Y conda build <recipe-dir>"
    exit 1
fi

if [[ ${target_platform} == osx-* ]]; then
    # The tarball extracts contents to the current directory
    # Install the main library file
    mkdir -p $PREFIX/lib
    cp -p lib/libmsodbcsql.18.dylib $PREFIX/lib/
    # Install resource files
    mkdir -p $PREFIX/share/msodbcsql18/resources/en_US
    cp -p share/msodbcsql18/resources/en_US/msodbcsqlr18.rll $PREFIX/share/msodbcsql18/resources/en_US/
    # Install header files
    mkdir -p $PREFIX/include/msodbcsql18
    cp -p include/msodbcsql18/msodbcsql.h $PREFIX/include/msodbcsql18/
    # Install documentation
    mkdir -p $PREFIX/share/doc/msodbcsql18
    cp -p share/doc/msodbcsql18/LICENSE.txt $PREFIX/share/doc/msodbcsql18/
    cp -p share/doc/msodbcsql18/RELEASE_NOTES $PREFIX/share/doc/msodbcsql18/
    # Set access permissions
    chmod 0444 $PREFIX/lib/libmsodbcsql.18.dylib
    chmod 0444 $PREFIX/share/msodbcsql18/resources/en_US/msodbcsqlr18.rll
    chmod 0644 $PREFIX/include/msodbcsql18/msodbcsql.h
    chmod 0644 $PREFIX/share/doc/msodbcsql18/LICENSE.txt
    chmod 0644 $PREFIX/share/doc/msodbcsql18/RELEASE_NOTES
    
    # Create directory for configuration
    mkdir -p $PREFIX/etc
    
    # Create odbcinst.ini template for use during activation
    cat > $PREFIX/etc/odbcinst.ini << EOF
[ODBC Driver 18 for SQL Server]
Description=Microsoft ODBC Driver 18 for SQL Server
Driver=$PREFIX/lib/libmsodbcsql.18.dylib
UsageCount=1
EOF

elif [[ ${target_platform} == linux-* ]]; then
    # For Linux, extract the .deb package
    mkdir -p tmp_extract
    tar -xf data.tar.xz -C tmp_extract
    
    # Install the main library file
    mkdir -p $PREFIX/lib
    cp -p tmp_extract/opt/microsoft/msodbcsql18/lib64/libmsodbcsql-18.4.so.1.1 $PREFIX/lib/
    
    # Create symbolic link
    ln -sf $PREFIX/lib/libmsodbcsql-18.4.so.1.1 $PREFIX/lib/libmsodbcsql-18.so
    
    # Install resource files
    mkdir -p $PREFIX/share/msodbcsql18/resources/en_US
    cp -p tmp_extract/opt/microsoft/msodbcsql18/share/resources/en_US/msodbcsqlr18.rll $PREFIX/share/msodbcsql18/resources/en_US/
    
    # Install header files
    mkdir -p $PREFIX/include/msodbcsql18
    cp -p tmp_extract/opt/microsoft/msodbcsql18/include/msodbcsql.h $PREFIX/include/msodbcsql18/
    
    # Install documentation
    mkdir -p $PREFIX/share/doc/msodbcsql18
    cp -p tmp_extract/usr/share/doc/msodbcsql18/LICENSE.txt $PREFIX/share/doc/msodbcsql18/
    
    # Create directory for configuration
    mkdir -p $PREFIX/etc
    
    # Create odbcinst.ini template for use during activation
    cat > $PREFIX/etc/odbcinst.ini << EOF
[ODBC Driver 18 for SQL Server]
Description=Microsoft ODBC Driver 18 for SQL Server
Driver=$PREFIX/lib/libmsodbcsql-18.4.so.1.1
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
cp $PREFIX/share/doc/msodbcsql18/LICENSE.txt $PREFIX/share/licenses/$PKG_NAME/

# Create directories for activate/deactivate scripts
mkdir -p $PREFIX/etc/conda/activate.d
mkdir -p $PREFIX/etc/conda/deactivate.d

# Copy scripts from recipe
cp $RECIPE_DIR/activate.sh $PREFIX/etc/conda/activate.d/msodbcsql18.sh
cp $RECIPE_DIR/deactivate.sh $PREFIX/etc/conda/deactivate.d/msodbcsql18.sh

# Make scripts executable
chmod +x $PREFIX/etc/conda/activate.d/msodbcsql18.sh
chmod +x $PREFIX/etc/conda/deactivate.d/msodbcsql18.sh
