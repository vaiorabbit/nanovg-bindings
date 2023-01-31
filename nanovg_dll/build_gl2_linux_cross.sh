#!/bin/sh
mkdir -p build_gl2
cd build_gl2
cmake -D CMAKE_C_FLAGS=-isystem\ /usr/aarch64-linux-gnu/include -D CMAKE_BUILD_TYPE=Release -D CMAKE_C_COMPILER_TARGET=aarch64-linux-gnu -D CMAKE_SYSTEM_PROCESSOR=ARM -D BUILD_SHARED_LIBS=ON -D -D CMAKE_C_COMPILER=clang ../gl2
make
export ARCH=aarch64
cp libnanovg_gl2.so ../../lib/libnanovg_gl2.${ARCH}.so
