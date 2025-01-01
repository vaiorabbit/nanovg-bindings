#!/bin/sh
mkdir -p build_gl3
cd build_gl3
cmake -D OpenGL_GL_PREFERENCE=GLVND -D CMAKE_C_FLAGS="" CMAKE_BUILD_TYPE=Release -D BUILD_SHARED_LIBS=ON -D CMAKE_C_COMPILER=clang ../gl3
cmake --build .
export ARCH=`uname -m`
cp libnanovg_gl3.so ../../lib/libnanovg_gl3.${ARCH}.so
