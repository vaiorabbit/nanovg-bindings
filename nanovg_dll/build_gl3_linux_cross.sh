#!/bin/sh
mkdir -p build_gl3
cd build_gl3
cmake -D CMAKE_C_FLAGS=-isystem\ /usr/aarch64-linux-gnu/include -D CMAKE_BUILD_TYPE=Release -D CMAKE_C_COMPILER_TARGET=aarch64-linux-gnu -D CMAKE_SYSTEM_PROCESSOR=aarch64 -D CMAKE_LIBRARY_PATH="/usr/aarch64-linux-gnu/lib;/lib/aarch64-linux-gnu" -D BUILD_SHARED_LIBS=ON -D CMAKE_C_COMPILER=clang ../gl3
cmake --build .
export ARCH=aarch64
cp libnanovg_gl3.so ../../lib/libnanovg_gl3.${ARCH}.so
