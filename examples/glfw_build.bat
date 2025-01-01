::
:: For Windows + RubyInstaller2 with DevKit(MSYS2 gcc & make) + CMake users.
:: - Use this script after "ridk enable"d. See https://github.com/oneclick/rubyinstaller2/wiki/The-ridk-tool for details.
::
:: Usage
:: > ridk enable
:: > glfw_build.bat  <- %PROGRAMFILES%\CMake\bin\cmake.exe will be used.
:: > glfw_build.bat "D:\Program Files\CMake\bin\cmake.exe" <- You can give full path to 'cmake.exe'.
@echo off
setlocal enabledelayedexpansion

set CMAKE_EXE=%1
if %CMAKE_EXE% == "" (
    set CMAKE_EXE="%PROGRAMFILES%\CMake\bin\cmake"
)

git clone --depth=1 https://github.com/glfw/glfw.git glfw
cd glfw/
mkdir build
cd build
%CMAKE_EXE% -G "MSYS Makefiles" -D CMAKE_BUILD_TYPE=Release -D GLFW_NATIVE_API=1 -D BUILD_SHARED_LIBS=ON -D CMAKE_C_COMPILER=gcc ../
make
cp -R src/glfw3.dll ../../../sample
