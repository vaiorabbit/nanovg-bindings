#
# For macOS + CMake users.
#
mkdir build_gl2_x86_64
cd build_gl2_x86_64
export MACOSX_DEPLOYMENT_TARGET=15.0
cmake -D CMAKE_BUILD_TYPE=Release -D CMAKE_OSX_ARCHITECTURES="x86_64" -D BUILD_SHARED_LIBS=ON -D CMAKE_C_COMPILER=clang ../gl2
cmake --build .
cp libnanovg_gl2.dylib ../../lib/libnanovg_gl2.x86_64.dylib

cd ..

mkdir build_gl2_arm64
cd build_gl2_arm64
export MACOSX_DEPLOYMENT_TARGET=15.0
cmake -D CMAKE_BUILD_TYPE=Release -D CMAKE_OSX_ARCHITECTURES="arm64" -D BUILD_SHARED_LIBS=ON -D CMAKE_C_COMPILER=clang ../gl2
cmake --build .
cp libnanovg_gl2.dylib ../../lib/libnanovg_gl2.arm64.dylib
