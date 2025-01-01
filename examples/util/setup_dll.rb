def nanovg_bindings_gem_available?
  Gem::Specification.find_by_name('nanovg-bindings')
rescue Gem::LoadError
  false
rescue
  Gem.available?('nanovg-bindings')
end

if nanovg_bindings_gem_available?
  # puts("Loading from Gem system path.")
  require 'nanovg'

  s = Gem::Specification.find_by_name('nanovg-bindings')
  shared_lib_path = s.full_gem_path + '/lib/'

  case RUBY_PLATFORM
  when /mswin|msys|mingw|cygwin/
    NVG.load_lib(shared_lib_path + 'libnanovg_gl2.dll')
  when /darwin/
    arch = RUBY_PLATFORM.split('-')[0]
    NVG.load_lib(shared_lib_path + "libnanovg_gl2.#{arch}.dylib")
  when /linux/
    arch = RUBY_PLATFORM.split('-')[0]
    NVG.load_lib(shared_lib_path + "libnanovg_gl2.#{arch}.so")
  else
    raise RuntimeError, "setup_dll.rb : Unknown OS: #{RUBY_PLATFORM}"
  end
else
  # puts("Loaging from local path.")
  require '../lib/nanovg'

  case RUBY_PLATFORM
  when /mswin|msys|mingw|cygwin/
    NVG.load_lib(Dir.pwd + '/../lib/' + 'libnanovg_gl2.dll')
  when /darwin/
    arch = RUBY_PLATFORM.split('-')[0]
    NVG.load_lib(Dir.pwd + '/../lib/' + "libnanovg_gl2.#{arch}.dylib")
  when /linux/
    arch = RUBY_PLATFORM.split('-')[0]
    NVG.load_lib(Dir.pwd + '/../lib/' + "libnanovg_gl2.#{arch}.so")
  else
    raise RuntimeError, "setup_dll.rb : Unknown OS: #{RUBY_PLATFORM}"
  end
end
