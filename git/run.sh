#!/bin/sh
set -e
export LD_LIBRARY_PATH=$(pwd)/deps/lib
export BUILD_DIR=_build

if [ -z $1 ]; then
    echo "Must have <port> as an argument"
    exit 1
fi

mkdir -p $BUILD_DIR
gcc -L deps/lib -Ideps/include -o $BUILD_DIR/httpd.run main.c -lmicrohttpd -lgit2

echo "Success"

exec $BUILD_DIR/httpd.run $1
