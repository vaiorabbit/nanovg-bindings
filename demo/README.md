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
