
local action = _ACTION or ""

solution "nanovg"
	location ( "build" )
	configurations { "DebugDLL", "ReleaseDLL" }
	platforms {"native", "x64", "x32"}
	
	project "nanovg_gl2"
		language "C"
		includedirs { "../nanovg/src" }
		files { "nanovg_dll.c" }
		targetdir("build")
		defines { "_CRT_SECURE_NO_WARNINGS", "NANOVG_GL2_IMPLEMENTATION" }

		configuration "windows"
			postbuildcommands { "copy libnanovg_gl2.dll ..\\..\\demo" }
		
		configuration "not windows"
			postbuildcommands { "cp libnanovg_gl2.dylib ../../demo" }

		configuration "DebugDLL"
			kind "SharedLib"
			defines { "DEBUG", "NANOVG_DLL_BUILD" }
			flags { "Symbols", "ExtraWarnings" }
			linkoptions { "-framework OpenGL" }

		configuration "ReleaseDLL"
			kind "SharedLib"
			defines { "NDEBUG", "NANOVG_DLL_BUILD" }
			flags { "Optimize", "ExtraWarnings" }
			linkoptions { "-framework OpenGL" }

	project "nanovg_gl3"
		language "C"
		includedirs { "../nanovg/src" }
		files { "nanovg_dll.c" }
		targetdir("build")
		defines { "_CRT_SECURE_NO_WARNINGS", "NANOVG_GL3_IMPLEMENTATION" }

		configuration "windows"
			postbuildcommands { "copy libnanovg_gl2.dll ..\\..\\demo" }
		
		configuration "not windows"
			postbuildcommands { "cp libnanovg_gl2.dylib ../../demo" }

		configuration "DebugDLL"
			kind "SharedLib"
			defines { "DEBUG", "NANOVG_DLL_BUILD" }
			flags { "Symbols", "ExtraWarnings" }
			linkoptions { "-framework OpenGL" }

		configuration "ReleaseDLL"
			kind "SharedLib"
			defines { "NDEBUG", "NANOVG_DLL_BUILD" }
			flags { "Optimize", "ExtraWarnings" }
			linkoptions { "-framework OpenGL" }
