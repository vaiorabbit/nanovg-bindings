# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "nanovg-bindings"
  spec.version       = "0.1.0"
  spec.authors       = ["vaiorabbit"]
  spec.email         = ["vaiorabbit@gmail.com"]
  spec.summary       = %q{Bindings for NanoVG}
  spec.homepage      = "https://github.com/vaiorabbit/nanovg-bindings"
  spec.require_paths = ["lib"]
  spec.license       = "Zlib"
  spec.description   = <<-DESC
Ruby bindings for NanoVG ( https://github.com/memononen/nanovg ).
  DESC

  spec.required_ruby_version = '>= 3.0.0'

  spec.add_runtime_dependency 'ffi', '~> 1.15'
  spec.add_runtime_dependency 'opengl-bindings2', '~> 2'

  spec.files = Dir.glob("lib/*") +
               ["README.md", "LICENSE.txt", "ChangeLog"]
end
