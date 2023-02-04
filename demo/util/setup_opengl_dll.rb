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
      arch = RUBY_PLATFORM.split('-')[0]
      "/usr/lib/#{arch}-linux-gnu/libGL.so"
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
      arch = RUBY_PLATFORM.split('-')[0]
      "/usr/lib/#{arch}-linux-gnu/libglfw.so.3"
    else
      raise RuntimeError, "Unsupported platform."
    end
  end

end
