#
# Ref.: https://github.com/memononen/nanovg/blob/master/example/example_gl2.c
#
require 'opengl'
require 'glfw'
require_relative '../nanovg'
require_relative 'perf'
require_relative 'demo_data'

OpenGL.load_lib()
GLFW.load_lib()
NanoVG.load_dll('libnanovg_gl2.dylib')
#NanoVG.load_dll('./nanovg_gl2.dll', render_backend: :gl2)

include OpenGL
include GLFW
include NanoVG

errorcb = GLFW::create_callback(:GLFWerrorfun) do |error, desc|
  printf("GLFW error %d: %s\n", error, desc)
end

$blowup = false
$screenshot = false

# Press ESC to exit.
key = GLFW::create_callback(:GLFWkeyfun) do |window, key, scancode, action, mods|
  if key == GLFW_KEY_ESCAPE && action == GLFW_PRESS
    glfwSetWindowShouldClose(window, GL_TRUE)
  end
  if key == GLFW_KEY_SPACE && action == GLFW_PRESS
    $blowup = !$blowup
  end
  if key == GLFW_KEY_S && action == GLFW_PRESS
    $screenshot = true
  end
end

if __FILE__ == $0
  data = DemoData.new
  fps = PerfGraph.new(PerfGraph::GRAPH_RENDER_FPS, "Frame Time")
  prevt = 0.0

  if glfwInit() == GL_FALSE
    puts("Failed to init GLFW.")
    exit
  end

  glfwSetErrorCallback(errorcb)

  glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 2)
  glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 0)

  window = glfwCreateWindow( 1000, 600, "NanoVG", nil, nil )
  if window == 0
    glfwTerminate()
    exit
  end

  glfwSetKeyCallback( window, key )

  glfwMakeContextCurrent( window )

  nvgSetupGL2()
  vg = nvgCreateGL2(NVG_ANTIALIAS | NVG_STENCIL_STROKES | NVG_DEBUG)
  if vg == nil
    puts("Could not init nanovg.")
    exit
  end

  if data.load(vg) == -1
    exit
  end

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
    fps.update(dt)

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

    glViewport(0, 0, fbWidth, fbHeight)
    glClearColor(0.3, 0.3, 0.32, 1.0)
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT|GL_STENCIL_BUFFER_BIT)

    nvgBeginFrame(vg, winWidth, winHeight, pxRatio)

    data.render(vg, mx, my, winWidth, winHeight, t, $blowup)
    fps.render(vg, 5, 5)
    nvgEndFrame(vg)

    if $screenshot
      $screenshot = false
      data.save_screenshot(fbWidth, fbHeight, "dump.tga");
    end

    glfwSwapBuffers( window )
    glfwPollEvents()
  end

  data.free(vg)

  nvgDeleteGL2(vg)

  glfwTerminate()
end
