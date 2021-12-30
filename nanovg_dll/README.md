<!-- -*- mode:markdown; coding:utf-8; -*- -->

## Building libnanovg_gl2.dylib ##

### CMake ###

Build scripts are generated via CMake ( https://cmake.org ).
Please install it before proceed.

	$ brew install cmake # for macOS

### GLEXT ###

Windows version depends on glext.h.
*   You can download from https://www.opengl.org/registry/api/GL/glext.h
*   Then fix paths in premake4.lua:
    *   includedirs, and

### Steps ###

#### macOS ####

	$ ./nanovg_dll_build_gl2.sh
	$ ./nanovg_dll_build_gl3.sh

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

## libnanovg_gl2.dylib のビルド方法 ##

### CMake ###

ビルドスクリプトは CMake ( https://cmake.org ) で生成します.
持っていない場合は先にインストールしておいてください.

	$ brew install cmake # for macOS

### GLEXT ###

Windows版は glext.h に依存しています。
最新版はこちらから入手できます: https://www.opengl.org/registry/api/GL/glext.h
*   premake4.lua にある下記のパスに関する項目を修正してください:
    *   includedirs

### 手順 ###

#### macOS ####

	$ ./nanovg_dll_build_gl2.sh
	$ ./nanovg_dll_build_gl3.sh

#### Windows ####

	> %home%\Programs\premake\premake4.exe vs2012
	* build\nanovg.sln を Visual Studio でオープン。
	* nanovg_gl{2|3} を ReleaseDLL/x64 という構成にしてビルド。
	* nanovg_gl{2|3}.dll が demo フォルダーにコピーされています。

### メモ : モジュール定義ファイルの書き方 (nanovg_gl2.def) ###

nanovg.h では __declspec(dllexport) を使っていませんので、Windows環境でDLL化するためには
モジュール定義ファイル (xxx.def) を手書きして Visual Studio のリンカーに渡す必要があります。

	> %home%\Programs\premake\premake4.exe vs2012

* build\nanovg.sln を Visual Studio で開く
* nanovg_gl2.lib を Release/x64 という構成にしてビルド

	> dumpbin nanovg_gl2.lib /symbols > nanovg_gl2.lib.syms
	> grep "External" nanovg_gl2.lib.syms | grep "nvg" > nanovg_gl2_External_nvg.syms

* 'nanovg_gl2_External_nvg.syms' というテキストファイルに出てきたシンボルを nanovg_gl2.def に手書きで並べる。具体的には：

	LIBRARY	nanovg_gl2
	EXPORTS
		nvgBeginFrame
		nvgCancelFrame
		;...
