## Prerequisites ##

*   Ruby-FFI
	*   nanovg.rb depends on it.
	*   run 'gem install ffi'

*   opengl-bindings
	*   Provides glfw.rb, a ruby bindings of GLFW.
	*   run 'gem install opengl-bindings'

## Getting GLFW (http://www.glfw.org) ##

*   Windows
	*   Put glfw3.dll here.
	*   Windows pre-compiled binaries:
		*   http://www.glfw.org/download.html

*   Mac OS X
	*   run ./glfwXX_build_dylib.sh to get ./libglfw.dylib.

### Copyright Notice ###

GLFW is available under the zlib/libpng license.

	Copyright (c) 2002-2006 Marcus Geelnard
	Copyright (c) 2006-2010 Camilla Berglund <elmindreda@elmindreda.org>
	
	This software is provided 'as-is', without any express or implied
	warranty. In no event will the authors be held liable for any damages
	arising from the use of this software.
	
	Permission is granted to anyone to use this software for any purpose,
	including commercial applications, and to alter it and redistribute it
	freely, subject to the following restrictions:
	
	1. The origin of this software must not be misrepresented; you must not
	   claim that you wrote the original software. If you use this software
	   in a product, an acknowledgment in the product documentation would
	   be appreciated but is not required.
	
	2. Altered source versions must be plainly marked as such, and must not
	   be misrepresented as being the original software.
	
	3. This notice may not be removed or altered from any source
	   distribution.

## Getting GLUT ##

*   Windows
	*   Use freeglut (http://freeglut.sourceforge.net).
	*   Put freeglut.dll here.
	*   Windows pre-compiled binaries:
		*   http://www.transmissionzero.co.uk/software/freeglut-devel/

*   Mac OS X
	*   glut.rb refers /System/Library/Frameworks/GLUT.framework by default.
	*   If you want to use other GLUT dll, specify the dll path and file name
		via the arguments of 'GLUT.load_dll'.
		*   See util/setup_dll.rb for example.
			*   https://github.com/vaiorabbit/ruby-opengl/blob/master/sample/util/setup_dll.rb

-------------------------------------------------------------------------------

## 必要なもの ##

*   Ruby-FFI
	*   nanovg.rb がこれに依存しています。
	*   'gem install ffi' を実行してください。

*   opengl-bindings
	*   Ruby用のGLFWバインディング・glfw.rb を提供しています。
	*   'gem install opengl-bindings' を実行してください。

## GLFWのセットアップ (http://www.glfw.org) ##

*   Windows
	*   glfw3.dll をここに配置してください。
	*   コンパイル済みバイナリはこちら:
		*   http://www.glfw.org/download.html

*   Mac OS X
	*   ./glfwXX_build_dylib.sh を実行すると ./libglfw.dylib ができあがります。

### 著作権表記 ###

GLFW は zlib/libpng ライセンスの条件下で利用可能です。

	Copyright (c) 2002-2006 Marcus Geelnard
	Copyright (c) 2006-2010 Camilla Berglund <elmindreda@elmindreda.org>
	
	This software is provided 'as-is', without any express or implied
	warranty. In no event will the authors be held liable for any damages
	arising from the use of this software.
	
	Permission is granted to anyone to use this software for any purpose,
	including commercial applications, and to alter it and redistribute it
	freely, subject to the following restrictions:
	
	1. The origin of this software must not be misrepresented; you must not
	   claim that you wrote the original software. If you use this software
	   in a product, an acknowledgment in the product documentation would
	   be appreciated but is not required.
	
	2. Altered source versions must be plainly marked as such, and must not
	   be misrepresented as being the original software.
	
	3. This notice may not be removed or altered from any source
	   distribution.

## GLUTのセットアップ ##

*   Windows
	*   freeglut を使ってください (http://freeglut.sourceforge.net).
	*   freeglut.dll をここに配置してください。
	*   コンパイル済みバイナリはこちら:
		*   http://www.transmissionzero.co.uk/software/freeglut-devel/

*   Mac OS X
	*   glut.rb はデフォルトで /System/Library/Frameworks/GLUT.framework を使います。
	*   もしこれとは別のGLUTを使いたい場合は 'GLUT.load_dll' の引数で指定してください。
		*   util/setup_dll.rb が使用例となっています。
			*   https://github.com/vaiorabbit/ruby-opengl/blob/master/sample/util/setup_dll.rb
