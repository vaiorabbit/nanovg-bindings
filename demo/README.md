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

## ɬ�פʤ�� ##

*   Ruby-FFI
	*   nanovg.rb ������˰�¸���Ƥ��ޤ���
	*   'gem install ffi' ��¹Ԥ��Ƥ���������

*   opengl-bindings
	*   Ruby�Ѥ�GLFW�Х���ǥ��󥰡�glfw.rb ���󶡤��Ƥ��ޤ���
	*   'gem install opengl-bindings' ��¹Ԥ��Ƥ���������

## GLFW�Υ��åȥ��å� (http://www.glfw.org) ##

*   Windows
	*   glfw3.dll �򤳤������֤��Ƥ���������
	*   ����ѥ���ѤߥХ��ʥ�Ϥ�����:
		*   http://www.glfw.org/download.html

*   Mac OS X
	*   ./glfwXX_build_dylib.sh ��¹Ԥ���� ./libglfw.dylib ���Ǥ�������ޤ���

## GLUT�Υ��åȥ��å� ##

*   Windows
	*   freeglut ��ȤäƤ������� (http://freeglut.sourceforge.net).
	*   freeglut.dll �򤳤������֤��Ƥ���������
	*   ����ѥ���ѤߥХ��ʥ�Ϥ�����:
		*   http://www.transmissionzero.co.uk/software/freeglut-devel/

*   Mac OS X
	*   glut.rb �ϥǥե���Ȥ� /System/Library/Frameworks/GLUT.framework ��Ȥ��ޤ���
	*   �⤷����Ȥ��̤�GLUT��Ȥ��������� 'GLUT.load_dll' �ΰ����ǻ��ꤷ�Ƥ���������
		*   util/setup_dll.rb ��������ȤʤäƤ��ޤ���
			*   https://github.com/vaiorabbit/ruby-opengl/blob/master/sample/util/setup_dll.rb
