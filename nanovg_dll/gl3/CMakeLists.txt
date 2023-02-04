project(nanovg_gl3)
cmake_minimum_required(VERSION 3.0)

message(STATUS "CMAKE_HOST_SYSTEM_PROCESSOR=${CMAKE_HOST_SYSTEM_PROCESSOR}")
message(STATUS "CMAKE_SYSTEM_PROCESSOR=${CMAKE_SYSTEM_PROCESSOR}")
message(STATUS "CMAKE_C_COMPILER_TARGET=${CMAKE_C_COMPILER_TARGET}")

if (${CMAKE_C_COMPILER_TARGET} STREQUAL "aarch64-linux-gnu")
    message(STATUS "Configuring for Linux(aarch64)")
    find_path(OPENGL_INCLUDE_DIR GL/gl.h /usr/include)
    find_library(OPENGL_LIBRARIES NAMES GL GLX PATHS /lib/aarch64-linux-gnu)
else()
    message(STATUS "Configuring for Windows/macOS/Linux(x86_64)")
    find_package(OpenGL)
endif()

add_definitions("-DNANOVG_GL3_IMPLEMENTATION=1")
add_definitions("-DGL_SILENCE_DEPRECATION=1")

include_directories( ${CMAKE_CURRENT_LIST_DIR}/../nanovg/src )
include_directories( ${OPENGL_INCLUDE_DIR} )

set(NANOVG_SOURCES
    ${CMAKE_CURRENT_LIST_DIR}/../nanovg_dll.c
)

# For " Policy CMP0042 is not set: MACOSX_RPATH is enabled by default."
if (APPLE)
    set(CMAKE_MACOSX_RPATH ON)
endif (APPLE)

# add library and link
add_library(nanovg_gl3 SHARED ${NANOVG_SOURCES})

target_link_libraries( nanovg_gl3 ${OPENGL_LIBRARIES} )

if (APPLE)
    set_target_properties(nanovg_gl3 PROPERTIES
        XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY ""
	)
endif (APPLE)
