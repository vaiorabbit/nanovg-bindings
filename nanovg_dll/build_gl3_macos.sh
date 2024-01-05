#
# For macOS + CMake users.
#
mkdir build_gl3_x86_64
cd build_gl3_x86_64
export MACOSX_DEPLOYMENT_TARGET=14.0
cmake -D CMAKE_BUILD_TYPE=Release -D CMAKE_OSX_ARCHITECTURES="x86_64" -D BUILD_SHARED_LIBS=ON -D CMAKE_C_COMPILER=clang ../gl3
make
cp libnanovg_gl3.dylib ../../lib/libnanovg_gl3.x86_64.dylib

cd ..

mkdir build_gl3_arm64
cd build_gl3_arm64
export MACOSX_DEPLOYMENT_TARGET=14.0
cmake -D CMAKE_BUILD_TYPE=Release -D CMAKE_OSX_ARCHITECTURES="arm64" -D BUILD_SHARED_LIBS=ON -D CMAKE_C_COMPILER=clang ../gl3
make
cp libnanovg_gl3.dylib ../../lib/libnanovg_gl3.arm64.dylib
