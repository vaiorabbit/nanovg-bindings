## Building libnanovg_gl2.dylib ##

$ premake4 --cc=gcc --os=macosx gmake
	Building configurations...
	Running action 'gmake'...
	Generating build/Makefile...
	Generating build/nanovg_gl2.make...
	Generating build/nanovg_gl3.make...
	Done.

$ cd build

$ make config=releasedll nanovg_gl2
	==== Building nanovg_gl2 (releasedll) ====
	Creating obj/ReleaseDLL/nanovg_gl2
	nanovg_dll.c
	Linking nanovg_gl2

$ ls -l ../../demo/*dylib
	-rwxr-xr-x  1 foo  bar  209780  7 12 12:16 libnanovg_gl2.dylib

-------------------------------------------------------------------------------

## libnanovg_gl2.dylib のビルド方法 ##

$ premake4 --cc=gcc --os=macosx gmake
	Building configurations...
	Running action 'gmake'...
	Generating build/Makefile...
	Generating build/nanovg_gl2.make...
	Generating build/nanovg_gl3.make...
	Done.

$ cd build

$ make config=releasedll nanovg_gl2
	==== Building nanovg_gl2 (releasedll) ====
	Creating obj/ReleaseDLL/nanovg_gl2
	nanovg_dll.c
	Linking nanovg_gl2

$ ls -l ../../demo/*dylib
	-rwxr-xr-x  1 foo  bar  209780  7 12 12:16 libnanovg_gl2.dylib

