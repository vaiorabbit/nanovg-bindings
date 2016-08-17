# NanoVG-Bindings : A Ruby bindings of NanoVG #

Provides NanoVG ( https://github.com/memononen/nanovg ) interfaces for ruby (MRI).

*   Created : 2015-07-12
*   Last modified : 2016-08-17

## Prerequisites ##

*   Ruby-FFI ( https://github.com/ffi/ffi )
	*   $ gem install ffi

*   OpenGL context provider
	*   ex.) glut.rb or glfw.rb in opengl-bindings ( https://github.com/vaiorabbit/ruby-opengl )
	*   $ gem install opengl-bindings

## How to Use ##

1. Build NanoVG shared library
	*   See nanovg_dll

2. Include nanovg.rb in your script.
	*   ex.) require_relative 'nanovg'

3. Load shared library
	*   ex.) NanoVG.load_dll('libnanovg_gl2.dylib', render_backend: :gl2)

4. Setup OpenGL
	*   nvgSetupGL2() / nvgSetupGL3

See demo/example.rb for details.

## License ##

All source codes are available under the terms of the zlib/libpng license.

	NanoVG-Bindings : A Ruby bindings of NanoVG
	Copyright (c) 2015 vaiorabbit
	
	This software is provided 'as-is', without any express or implied
	warranty. In no event will the authors be held liable for any damages
	arising from the use of this software.
	
	Permission is granted to anyone to use this software for any purpose,
	including commercial applications, and to alter it and redistribute it
	freely, subject to the following restrictions:
	
	    1. The origin of this software must not be misrepresented; you must not
	    claim that you wrote the original software. If you use this software
	    in a product, an acknowledgment in the product documentation would be
	    appreciated but is not required.
	
	    2. Altered source versions must be plainly marked as such, and must not be
	    misrepresented as being the original software.
	
	    3. This notice may not be removed or altered from any source
	    distribution.
