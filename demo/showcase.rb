require 'opengl'
require 'glfw'
require_relative '../nanovg'
require_relative './showcase/scenes'

OpenGL.load_dll()
GLFW.load_dll()
NanoVG.load_dll('libnanovg_gl2.dylib')
#NanoVG.load_dll('./nanovg_gl2.dll', render_backend: :gl2)

include OpenGL
include GLFW
include NanoVG

$showcase = nil

# Press ESC to exit.
key = GLFW::create_callback(:GLFWkeyfun) do |window, key, scancode, action, mods|
  glfwSetWindowShouldClose(window, GL_TRUE) if key == GLFW_KEY_ESCAPE && action == GLFW_PRESS
  $showcase.next_scene if key == GLFW_KEY_N && action == GLFW_PRESS
  $showcase.prev_scene if key == GLFW_KEY_P && action == GLFW_PRESS
end

if __FILE__ == $0
  prevt = 0.0

  glfwInit()

  glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 2)
  glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 0)

  window = glfwCreateWindow( 1000, 600, "NanoVG", nil, nil )

  glfwSetKeyCallback( window, key )
  glfwMakeContextCurrent( window )

  nvgSetupGL2()
  vg = nvgCreateGL2(NVG_ANTIALIAS | NVG_STENCIL_STROKES | NVG_DEBUG)

  $showcase = Showcase.new

  glfwSwapInterval(0)
  glfwSetTime(0)
  prevt = glfwGetTime()

  mx_buf = '        '
  my_buf = '        '
  winWidth_buf  = '        '
  winHeight_buf = '        '
  fbWidth_buf  = '        '
  fbHeight_buf = '        '
  while glfwWindowShouldClose( window ) == 0
    t = glfwGetTime()
    dt = t - prevt
    prevt = t

    glfwGetCursorPos(window, mx_buf, my_buf)
    glfwGetWindowSize(window, winWidth_buf, winHeight_buf)
    glfwGetFramebufferSize(window, fbWidth_buf, fbHeight_buf)
    mx = mx_buf.unpack('D')[0]
    my = my_buf.unpack('D')[0]
    winWidth = winWidth_buf.unpack('L')[0]
    winHeight = winHeight_buf.unpack('L')[0]
    fbWidth = fbWidth_buf.unpack('L')[0]
    fbHeight = fbHeight_buf.unpack('L')[0]

    pxRatio = fbWidth.to_f / winWidth.to_f

    $showcase.set_viewport_size(fbWidth, fbHeight)

    glViewport(0, 0, fbWidth, fbHeight)
    glClearColor(0.3, 0.3, 0.32, 1.0)
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT|GL_STENCIL_BUFFER_BIT)

    nvgBeginFrame(vg, winWidth, winHeight, pxRatio)
    $showcase.render(vg, dt)
    nvgEndFrame(vg)

    glfwSwapBuffers( window )
    glfwPollEvents()
  end

  nvgDeleteGL2(vg)

  glfwTerminate()
end
