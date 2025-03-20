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
    # The tarball extracts its contents to the current directory
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
    # Set permissions
    chmod 0444 $PREFIX/lib/libmsodbcsql.18.dylib
    chmod 0444 $PREFIX/share/msodbcsql18/resources/en_US/msodbcsqlr18.rll
    chmod 0644 $PREFIX/include/msodbcsql18/msodbcsql.h
    chmod 0644 $PREFIX/share/doc/msodbcsql18/LICENSE.txt
    chmod 0644 $PREFIX/share/doc/msodbcsql18/RELEASE_NOTES
    # Copy odbcinst.ini to prefix for use by post-link.sh
    cp odbcinst.ini $PREFIX
fi

if [[ ${target_platform} == linux-* ]]; then
    mkdir -p $SRC_DIR/data
    #ls -la $SRC_DIR
    tar -xf $SRC_DIR/data.tar.xz -C $SRC_DIR/data
    #ls -la $SRC_DIR/msodbcsql18
    #cp -r $SRC_DIR/msodbcsql18/* $PREFIX
    mkdir -p $PREFIX/lib
    cp -P $SRC_DIR/data/opt/microsoft/msodbcsql18/lib64/libmsodbcsql-*.so* $PREFIX/lib/
    # Include files
    mkdir -p $PREFIX/include/msodbcsql18
    cp -r $SRC_DIR/data/opt/microsoft/msodbcsql18/include/* $PREFIX/include/msodbcsql18/
    # Documentation
    mkdir -p $PREFIX/share/doc/msodbcsql18
    cp -r $SRC_DIR/data/usr/share/doc/msodbcsql18/* $PREFIX/share/doc/msodbcsql18/
    # Resources
    mkdir -p $PREFIX/share/msodbcsql18/resources/en_US
    cp -r $SRC_DIR/data/opt/microsoft/msodbcsql18/share/resources/en_US/* $PREFIX/share/msodbcsql18/resources/en_US/
    # Extract the odbcinst.ini template from Debian package
    mkdir -p $PREFIX/share/msodbcsql18/resources/en_US
    
    # Set permissions
    chmod 0644 $PREFIX/include/msodbcsql18/*
    chmod 0644 $PREFIX/share/doc/msodbcsql18/*
    chmod 0755 $PREFIX/lib/libmsodbcsql-*.so*
    chmod 0644 $PREFIX/share/msodbcsql18/resources/en_US/*
    # Copy odbcinst.ini to prefix for use by post-link.sh
    cp $SRC_DIR/data/opt/microsoft/msodbcsql18/etc/odbcinst.ini $PREFIX/
fi


