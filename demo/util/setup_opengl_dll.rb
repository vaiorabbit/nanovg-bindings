require 'opengl'
require 'glfw'

module SampleUtil

  def self.gl_library_path()
    case GL.get_platform
    when :OPENGL_PLATFORM_WINDOWS
      'C:/Windows/System32/opengl32.dll'
    when :OPENGL_PLATFORM_MACOSX
      '/System/Library/Frameworks/OpenGL.framework/Libraries/libGL.dylib'
    when :OPENGL_PLATFORM_LINUX
      '/usr/lib/x86_64-linux-gnulibGL.so' # note tested
    else
      raise RuntimeError, "Unsupported platform."
    end
  end

  def self.glfw_library_path()
    case GL.get_platform
    when :OPENGL_PLATFORM_WINDOWS
      Dir.pwd + '/glfw3.dll'
    when :OPENGL_PLATFORM_MACOSX
      './libglfw.dylib'
    when :OPENGL_PLATFORM_LINUX
      '/usr/lib/x86_64-linux-gnu/libglfw.so' # not testeda
    else
      raise RuntimeError, "Unsupported platform."
    end
  end

end
