require '../lib/nanovg'

case RUBY_PLATFORM
when /mswin|msys|mingw|cygwin/
  NVG.load_lib(Dir.pwd + '/../lib/' + 'libnanovg_gl2.dll')
when /darwin/
  NVG.load_lib(Dir.pwd + '/../lib/' + 'libnanovg_gl2.dylib')
when /linux/
  arch = RUBY_PLATFORM.split('-')[0]
  NVG.load_lib(Dir.pwd + '/../lib/' + "libnanovg_gl2.#{arch}.so")
else
  raise RuntimeError, "setup_dll.rb : Unknown OS: #{RUBY_PLATFORM}"
end
