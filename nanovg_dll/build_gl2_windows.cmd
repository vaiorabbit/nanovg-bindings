::
:: For Windows + RubyInstaller2 with DevKit(MSYS2 gcc & make) + CMake users.
:: - Use this script after "ridk enable"d. See https://github.com/oneclick/rubyinstaller2/wiki/The-ridk-tool for details.
::
:: Usage
:: > ridk enable
:: > nanovg_gl2_build_windows.bat  <- %PROGRAMFILES%\CMake\bin\cmake.exe will be used.
:: > nanovg_gl2_build_windows.bat "D:\Program Files\CMake\bin\cmake.exe" <- You can give full path to 'cmake.exe'.

@echo off
setlocal enabledelayedexpansion
set TARGET=gl2
set CMAKE_EXE=%1
if %CMAKE_EXE% == "" (
    set CMAKE_EXE="%PROGRAMFILES%\CMake\bin\cmake"
)

pushd %~dp0

if not exist glext.h (
    curl -O https://raw.githubusercontent.com/KhronosGroup/OpenGL-Registry/main/api/GL/glext.h
)

if not exist build_%TARGET% (
    mkdir build_%TARGET%
)
cd build_%TARGET%

%CMAKE_EXE% -G "MSYS Makefiles" -D CMAKE_BUILD_TYPE=Release -D BUILD_SHARED_LIBS=ON -D CMAKE_C_COMPILER=gcc ../%TARGET%
make
copy libnanovg_%TARGET%.dll ..\..\lib

popd
