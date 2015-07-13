## Building libnanovg_gl2.dylib ##

### Premake ###

Build scripts are generated via Premake ( https://premake.github.io ).
Please install it before proceed.

	$ brew install premake # for Mac OS X

### GLEXT ###

Windows version depends on glext.h.
*   You can download from https://www.opengl.org/registry/api/GL/glext.h
*   Then fix paths in premake4.lua:
    *   includedirs, and

### Steps ###

#### Mac OS X ####

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

#### Windows ####

	> %home%\Programs\premake\premake4.exe vs2012
	* Open build\nanovg.sln with Visual Studio
	* Build nanovg_gl{2|3} with ReleaseDLL/x64 configuration.
	* You get nanovg_gl{2|3}.dll in demo folder.

### Memo : How to write module definition file (nanovg_gl2.def) ###

Current nanovg.h does not use __declspec(dllexport), so we have to write
a module definition file (xxx.def) by hand and pass it to Visual Studio linker.

	> %home%\Programs\premake\premake4.exe vs2012

* Open build\nanovg.sln with Visual Studio
* Build nanovg_gl2.lib with Release/x64 configuration.

	> dumpbin nanovg_gl2.lib /symbols > nanovg_gl2.lib.syms
	> grep "External" nanovg_gl2.lib.syms | grep "nvg" > nanovg_gl2_External_nvg.syms

* Write out symbols in the text file 'nanovg_gl2_External_nvg.syms' into nanovg_gl2.def by hand like:

	LIBRARY	nanovg_gl2
	EXPORTS
		nvgBeginFrame
		nvgCancelFrame
		;...

-------------------------------------------------------------------------------

## libnanovg_gl2.dylib �Υӥ����ˡ ##

### Premake ###

�ӥ�ɥ�����ץȤ� Premake ( https://premake.github.io ) ���������ޤ�.
���äƤ��ʤ�������˥��󥹥ȡ��뤷�Ƥ����Ƥ�������.

	$ brew install premake # for Mac OS X

### GLEXT ###

Windows�Ǥ� glext.h �˰�¸���Ƥ��ޤ���
�ǿ��ǤϤ����餫������Ǥ��ޤ�: https://www.opengl.org/registry/api/GL/glext.h
*   premake4.lua �ˤ��벼���Υѥ��˴ؤ�����ܤ������Ƥ�������:
    *   includedirs

### ��� ###

#### Mac OS X ####

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

#### Windows ####

	> %home%\Programs\premake\premake4.exe vs2012
	* build\nanovg.sln �� Visual Studio �ǥ����ץ�
	* nanovg_gl{2|3} �� ReleaseDLL/x64 �Ȥ��������ˤ��ƥӥ�ɡ�
	* nanovg_gl{2|3}.dll �� demo �ե�������˥��ԡ�����Ƥ��ޤ���

### ��� : �⥸�塼������ե�����ν��� (nanovg_gl2.def) ###

nanovg.h �Ǥ� __declspec(dllexport) ��ȤäƤ��ޤ���Τǡ�Windows�Ķ���DLL�����뤿��ˤ�
�⥸�塼������ե����� (xxx.def) ���񤭤��� Visual Studio �Υ�󥫡����Ϥ�ɬ�פ�����ޤ���

	> %home%\Programs\premake\premake4.exe vs2012

* build\nanovg.sln �� Visual Studio �ǳ���
* nanovg_gl2.lib �� Release/x64 �Ȥ��������ˤ��ƥӥ��

	> dumpbin nanovg_gl2.lib /symbols > nanovg_gl2.lib.syms
	> grep "External" nanovg_gl2.lib.syms | grep "nvg" > nanovg_gl2_External_nvg.syms

* 'nanovg_gl2_External_nvg.syms' �Ȥ����ƥ����ȥե�����˽ФƤ�������ܥ�� nanovg_gl2.def �˼�񤭤��¤٤롣����Ū�ˤϡ�

	LIBRARY	nanovg_gl2
	EXPORTS
		nvgBeginFrame
		nvgCancelFrame
		;...
