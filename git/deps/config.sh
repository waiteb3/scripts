DEPS="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "./configure --prefix=$(pwd)/deps && make && make install"

echo

echo "cmake .. -DBIN_INSTALL_DIR=$DEPS/bin -DLIB_INSTALL_DIR=$DEPS/lib -DINCLUDE_INSTALL_DIR=$DEPS/include"
echo "cmake --build ."
echo "make install"
