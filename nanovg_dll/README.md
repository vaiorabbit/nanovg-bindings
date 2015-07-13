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

## libnanovg_gl2.dylib �Υӥ����ˡ ##

### Premake ###

�ӥ�ɥ�����ץȤ� Premake ( https://premake.github.io ) ���������ޤ�.
���äƤ��ʤ�������˥��󥹥ȡ��뤷�Ƥ����Ƥ�������.

	$ brew install premake # for Mac OS X

### GLEW ###

Windows�Ǥ� GLEW �˰�¸���Ƥ��ޤ���
*   �ӥ�ɺѤߤΥ饤�֥��Ϥ����餫������Ǥ��ޤ�: http://glew.sourceforge.net/
*   premake4.lua �ˤ��벼���Υѥ��˴ؤ�����ܤ������Ƥ�������:
    *   includedirs
    *   libdirs

### ��� ###

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

