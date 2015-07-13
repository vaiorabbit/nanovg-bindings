## Building libnanovg_gl2.dylib ##

### Premake ###

Build scripts are generated via Premake ( https://premake.github.io ).
Please install it before proceed.

	$ brew install premake # for Mac OS X

### GLEW ###

Windows version depends on GLEW.
*   You can download pre-built libraries at http://glew.sourceforge.net/ .
*   Then fix paths in premake4.lua:
    *   includedirs, and
    *   libdirs.

### Steps ###

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

### Premake ###

ビルドスクリプトは Premake ( https://premake.github.io ) で生成します.
持っていない場合は先にインストールしておいてください.

	$ brew install premake # for Mac OS X

### GLEW ###

Windows版は GLEW に依存しています。
*   ビルド済みのライブラリはこちらから入手できます: http://glew.sourceforge.net/
*   premake4.lua にある下記のパスに関する項目を修正してください:
    *   includedirs
    *   libdirs

### 手順 ###

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

