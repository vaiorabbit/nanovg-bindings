project(nanovg_gl3)
cmake_minimum_required(VERSION 3.0)

find_package(OpenGL)

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
