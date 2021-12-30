#
# For macOS + CMake users.
#
mkdir build_gl2
cd build_gl2
export MACOSX_DEPLOYMENT_TARGET=11.5
cmake -D CMAKE_BUILD_TYPE=Release -D CMAKE_OSX_ARCHITECTURES="arm64;x86_64" -D BUILD_SHARED_LIBS=ON -D CMAKE_C_COMPILER=clang ../gl2
make
cp *.dylib ../../demo
