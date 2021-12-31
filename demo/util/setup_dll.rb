require '../lib/nanovg'

case RUBY_PLATFORM
when /mswin|msys|mingw|cygwin/
  NanoVG.load_lib(Dir.pwd + '/' + 'libnanovg_gl2.dll')
when /darwin/
  NanoVG.load_lib(Dir.pwd + '/' + 'libnanovg_gl2.dylib')
when /linux/
  NanoVG.load_lib(Dir.pwd + '/' + 'libnanovg_gl2.so')
else
  raise RuntimeError, "setup_dll.rb : Unknown OS: #{RUBY_PLATFORM}"
end

include NanoVG
