#!/bin/bash

set -ex

if [[ ${target_platform} == osx-* ]]; then
    git clone https://github.com/Homebrew/brew

    $SRC_DIR/brew/bin/brew tap microsoft/mssql-release https://github.com/Microsoft/homebrew-mssql-release

    export HOMEBREW_CACHE=$SRC_DIR/empty_homebrew_cache
    mkdir -p $HOMEBREW_CACHE
    #$SRC_DIR/brew/bin/brew cleanup

    HOMEBREW_ACCEPT_EULA=Y $SRC_DIR/brew/bin/brew install msodbcsql18 mssql-tools18

    cp -r "$($SRC_DIR/brew/bin/brew --prefix msodbcsql18)" "$PREFIX"
    cp -r "$($SRC_DIR/brew/bin/brew --prefix mssql-tools18)" "$PREFIX"
fi

if [[ ${target_platform} == linux-* ]]; then
    mkdir -p $SRC_DIR/msodbcsql18
    ls -la $SRC_DIR
    tar -xf $SRC_DIR/data.tar.xz -C $SRC_DIR/msodbcsql18
    ls -la $SRC_DIR/msodbcsql18
    cp -r $SRC_DIR/msodbcsql18/* $PREFIX
fi


