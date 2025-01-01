#!/bin/sh
mkdir -p build_gl2
cd build_gl2
cmake -D CMAKE_C_FLAGS="" CMAKE_BUILD_TYPE=Release -D BUILD_SHARED_LIBS=ON -D CMAKE_C_COMPILER=clang ../gl2
cmake --build .
export ARCH=`uname -m`
cp libnanovg_gl2.so ../../lib/libnanovg_gl2.${ARCH}.so
