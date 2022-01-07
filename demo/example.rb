#
# Ref.: https://github.com/memononen/nanovg/blob/master/example/example_gl2.c
#

require_relative 'util/setup_dll'
require_relative 'util/setup_opengl_dll'

require_relative 'lib/perf'
require_relative 'lib/demo_data'

errorcb = GLFW::create_callback(:GLFWerrorfun) do |error, desc|
  printf("GLFW error %d: %s\n", error, desc)
end

$blowup = false
$screenshot = false

# Press ESC to exit.
key = GLFW::create_callback(:GLFWkeyfun) do |window, key, scancode, action, mods|
  if key == GLFW::KEY_ESCAPE && action == GLFW::PRESS
    GLFW.SetWindowShouldClose(window, GL::TRUE)
  end
  if key == GLFW::KEY_SPACE && action == GLFW::PRESS
    $blowup = !$blowup
  end
  if key == GLFW::KEY_S && action == GLFW::PRESS
    $screenshot = true
  end
end

if __FILE__ == $PROGRAM_NAME

  GLFW.load_lib(SampleUtil.glfw_library_path)

  data = DemoData.new
  fps = PerfGraph.new(PerfGraph::GRAPH_RENDER_FPS, "Frame Time")
  prevt = 0.0

  if GLFW.Init() == GL::FALSE
    puts("Failed to init GLFW.")
    exit
  end

  GLFW.SetErrorCallback(errorcb)

  GLFW.WindowHint(GLFW::CONTEXT_VERSION_MAJOR, 2)
  GLFW.WindowHint(GLFW::CONTEXT_VERSION_MINOR, 0)

  window = GLFW.CreateWindow(1000, 600, "NanoVG", nil, nil)
  if window == 0
    GLFW.Terminate()
    exit
  end

  GLFW.SetKeyCallback(window, key)

  GLFW.MakeContextCurrent(window)

  GL.load_lib()

  nvgSetupGL2()
  vg = nvgCreateGL2(NVG_ANTIALIAS | NVG_STENCIL_STROKES | NVG_DEBUG)
  if vg == nil
    puts("Could not init nanovg.")
    exit
  end

  if data.load(vg) == -1
    exit
  end

  GLFW.SwapInterval(0)
  GLFW.SetTime(0)
  prevt = GLFW.GetTime()

  mx_buf = ' ' * 8
  my_buf = ' ' * 8
  winWidth_buf  = ' ' * 8
  winHeight_buf = ' ' * 8
  fbWidth_buf  = ' ' * 8
  fbHeight_buf = ' ' * 8
  while GLFW.WindowShouldClose(window) == 0
    t = GLFW.GetTime()
    dt = t - prevt
    prevt = t
    fps.update(dt)

    GLFW.GetCursorPos(window, mx_buf, my_buf)
    GLFW.GetWindowSize(window, winWidth_buf, winHeight_buf)
    GLFW.GetFramebufferSize(window, fbWidth_buf, fbHeight_buf)
    mx = mx_buf.unpack('D')[0]
    my = my_buf.unpack('D')[0]
    winWidth = winWidth_buf.unpack('L')[0]
    winHeight = winHeight_buf.unpack('L')[0]
    fbWidth = fbWidth_buf.unpack('L')[0]
    fbHeight = fbHeight_buf.unpack('L')[0]

    pxRatio = fbWidth.to_f / winWidth.to_f

    GL.Viewport(0, 0, fbWidth, fbHeight)
    GL.ClearColor(0.3, 0.3, 0.32, 1.0)
    GL.Clear(GL::COLOR_BUFFER_BIT|GL::DEPTH_BUFFER_BIT|GL::STENCIL_BUFFER_BIT)

    nvgBeginFrame(vg, winWidth, winHeight, pxRatio)

    data.render(vg, mx, my, winWidth, winHeight, t, $blowup)
    fps.render(vg, 5, 5)
    nvgEndFrame(vg)

    if $screenshot
      $screenshot = false
      data.save_screenshot(fbWidth, fbHeight, "dump.tga")
    end

    GLFW.SwapBuffers(window)
    GLFW.PollEvents()
  end

  data.free(vg)

  nvgDeleteGL2(vg)

  GLFW.Terminate()
end
