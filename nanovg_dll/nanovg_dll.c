#if defined(__APPLE__)
#include <OpenGL/gl.h>
#elif defined(_WIN32)
#define WIN32_LEAN_AND_MEAN
#include "windows.h"
#include <GL/gl.h>
#include <GL/glext.h>
#endif

#if defined(_WIN32)
PFNGLACTIVETEXTUREPROC             glActiveTexture              = NULL;
PFNGLATTACHSHADERPROC              glAttachShader               = NULL;
PFNGLBINDATTRIBLOCATIONPROC        glBindAttribLocation         = NULL;
PFNGLBINDBUFFERPROC                glBindBuffer                 = NULL;
PFNGLBUFFERDATAPROC                glBufferData                 = NULL;
PFNGLCOMPILESHADERPROC             glCompileShader              = NULL;
PFNGLCREATEPROGRAMPROC             glCreateProgram              = NULL;
PFNGLCREATESHADERPROC              glCreateShader               = NULL;
PFNGLDELETEBUFFERSPROC             glDeleteBuffers              = NULL;
PFNGLDELETEPROGRAMPROC             glDeleteProgram              = NULL;
PFNGLDELETESHADERPROC              glDeleteShader               = NULL;
PFNGLDISABLEVERTEXATTRIBARRAYPROC  glDisableVertexAttribArray   = NULL;
PFNGLENABLEVERTEXATTRIBARRAYPROC   glEnableVertexAttribArray    = NULL;
PFNGLGENBUFFERSPROC                glGenBuffers                 = NULL;
PFNGLGETPROGRAMINFOLOGPROC         glGetProgramInfoLog          = NULL;
PFNGLGETPROGRAMIVPROC              glGetProgramiv               = NULL;
PFNGLGETSHADERINFOLOGPROC          glGetShaderInfoLog           = NULL;
PFNGLGETSHADERIVPROC               glGetShaderiv                = NULL;
PFNGLGETUNIFORMLOCATIONPROC        glGetUniformLocation         = NULL;
PFNGLLINKPROGRAMPROC               glLinkProgram                = NULL;
PFNGLSHADERSOURCEPROC              glShaderSource               = NULL;
PFNGLSTENCILOPSEPARATEPROC         glStencilOpSeparate          = NULL;
PFNGLUNIFORM1IPROC                 glUniform1i                  = NULL;
PFNGLUNIFORM2FVPROC                glUniform2fv                 = NULL;
PFNGLUNIFORM4FVPROC                glUniform4fv                 = NULL;
PFNGLUSEPROGRAMPROC                glUseProgram                 = NULL;
PFNGLVERTEXATTRIBPOINTERPROC       glVertexAttribPointer        = NULL;

PFNGLBINDBUFFERRANGEPROC        glBindBufferRange       = NULL;
PFNGLBINDVERTEXARRAYPROC        glBindVertexArray       = NULL;
PFNGLDELETEVERTEXARRAYSPROC     glDeleteVertexArrays    = NULL;
PFNGLGENERATEMIPMAPPROC         glGenerateMipmap        = NULL;
PFNGLGENVERTEXARRAYSPROC        glGenVertexArrays       = NULL;
PFNGLGETUNIFORMBLOCKINDEXPROC   glGetUniformBlockIndex  = NULL;
PFNGLUNIFORMBLOCKBINDINGPROC    glUniformBlockBinding   = NULL;

#endif // defined(_WIN32)

void nvgSetupGL2()
{
#if defined(_WIN32)
    glActiveTexture            = (PFNGLACTIVETEXTUREPROC)wglGetProcAddress("glActiveTexture");
    glAttachShader             = (PFNGLATTACHSHADERPROC)wglGetProcAddress("glAttachShader");
    glBindAttribLocation       = (PFNGLBINDATTRIBLOCATIONPROC)wglGetProcAddress("glBindAttribLocation");
    glBindBuffer               = (PFNGLBINDBUFFERPROC)wglGetProcAddress("glBindBuffer");
    glBufferData               = (PFNGLBUFFERDATAPROC)wglGetProcAddress("glBufferData");
    glCompileShader            = (PFNGLCOMPILESHADERPROC)wglGetProcAddress("glCompileShader");
    glCreateProgram            = (PFNGLCREATEPROGRAMPROC)wglGetProcAddress("glCreateProgram");
    glCreateShader             = (PFNGLCREATESHADERPROC)wglGetProcAddress("glCreateShader");
    glDeleteBuffers            = (PFNGLDELETEBUFFERSPROC)wglGetProcAddress("glDeleteBuffers");
    glDeleteProgram            = (PFNGLDELETEPROGRAMPROC)wglGetProcAddress("glDeleteProgram");
    glDeleteShader             = (PFNGLDELETESHADERPROC)wglGetProcAddress("glDeleteShader");
    glDisableVertexAttribArray = (PFNGLDISABLEVERTEXATTRIBARRAYPROC)wglGetProcAddress("glDisableVertexAttribArray");
    glEnableVertexAttribArray  = (PFNGLENABLEVERTEXATTRIBARRAYPROC)wglGetProcAddress("glEnableVertexAttribArray");
    glGenBuffers               = (PFNGLGENBUFFERSPROC)wglGetProcAddress("glGenBuffers");
    glGetProgramInfoLog        = (PFNGLGETPROGRAMINFOLOGPROC)wglGetProcAddress("glGetProgramInfoLog");
    glGetProgramiv             = (PFNGLGETPROGRAMIVPROC)wglGetProcAddress("glGetProgramiv");
    glGetShaderInfoLog         = (PFNGLGETSHADERINFOLOGPROC)wglGetProcAddress("glGetShaderInfoLog");
    glGetShaderiv              = (PFNGLGETSHADERIVPROC)wglGetProcAddress("glGetShaderiv");
    glGetUniformLocation       = (PFNGLGETUNIFORMLOCATIONPROC)wglGetProcAddress("glGetUniformLocation");
    glLinkProgram              = (PFNGLLINKPROGRAMPROC)wglGetProcAddress("glLinkProgram");
    glShaderSource             = (PFNGLSHADERSOURCEPROC)wglGetProcAddress("glShaderSource");
    glStencilOpSeparate        = (PFNGLSTENCILOPSEPARATEPROC)wglGetProcAddress("glStencilOpSeparate");
    glUniform1i                = (PFNGLUNIFORM1IPROC)wglGetProcAddress("glUniform1i");
    glUniform2fv               = (PFNGLUNIFORM2FVPROC)wglGetProcAddress("glUniform2fv");
    glUniform4fv               = (PFNGLUNIFORM4FVPROC)wglGetProcAddress("glUniform4fv");
    glUseProgram               = (PFNGLUSEPROGRAMPROC)wglGetProcAddress("glUseProgram");
    glVertexAttribPointer      = (PFNGLVERTEXATTRIBPOINTERPROC)wglGetProcAddress("glVertexAttribPointer");
#endif // defined(_WIN32)
}

void nvgSetupGL3()
{
#if defined(_WIN32)
    nvgSetupGL2();
    glBindBufferRange = (PFNGLBINDBUFFERRANGEPROC)wglGetProcAddress("glBindBufferRange");
    glBindVertexArray = (PFNGLBINDVERTEXARRAYPROC)wglGetProcAddress("glBindVertexArray");
    glDeleteVertexArrays = (PFNGLDELETEVERTEXARRAYSPROC)wglGetProcAddress("glDeleteVertexArrays");
    glGenerateMipmap = (PFNGLGENERATEMIPMAPPROC)wglGetProcAddress("glGenerateMipmap");
    glGenVertexArrays = (PFNGLGENVERTEXARRAYSPROC)wglGetProcAddress("glGenVertexArrays");
    glGetUniformBlockIndex = (PFNGLGETUNIFORMBLOCKINDEXPROC)wglGetProcAddress("glGetUniformBlockIndex");
    glUniformBlockBinding = (PFNGLUNIFORMBLOCKBINDINGPROC)wglGetProcAddress("glUniformBlockBinding");
#endif // defined(_WIN32)
}

#include "nanovg.h"
#include "nanovg.c"
#include "nanovg_gl.h"
