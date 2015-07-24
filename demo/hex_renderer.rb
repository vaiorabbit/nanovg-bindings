require 'opengl'
require 'glfw'
require_relative '../nanovg'
require_relative 'hex'

OpenGL.load_dll()
GLFW.load_dll()
NanoVG.load_dll('libnanovg_gl2.dylib')

include OpenGL
include GLFW
include NanoVG

# Press ESC to exit.
key = GLFW::create_callback(:GLFWkeyfun) do |window, key, scancode, action, mods|
  if key == GLFW_KEY_ESCAPE && action == GLFW_PRESS
    glfwSetWindowShouldClose(window, GL_TRUE)
  end
end

if __FILE__ == $0

  if glfwInit() == GL_FALSE
    puts("Failed to init GLFW.")
    exit
  end

  glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 2)
  glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 0)

  window = glfwCreateWindow( 1280, 720, "Hex Grid Renderer", nil, nil )
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

  glfwSwapInterval(0)
  glfwSetTime(0)

  winWidth_buf  = '        '
  winHeight_buf = '        '
  fbWidth_buf  = '        '
  fbHeight_buf = '        '

  hex_grid_layout = Layout.new(Layout::FLAT, Point.new(30, 30), Point.new(1280/2.0, 720/2.0))

  while glfwWindowShouldClose( window ) == 0

    glfwGetWindowSize(window, winWidth_buf, winHeight_buf)
    glfwGetFramebufferSize(window, fbWidth_buf, fbHeight_buf)
    winWidth = winWidth_buf.unpack('L')[0]
    winHeight = winHeight_buf.unpack('L')[0]
    fbWidth = fbWidth_buf.unpack('L')[0]
    fbHeight = fbHeight_buf.unpack('L')[0]

    pxRatio = fbWidth.to_f / winWidth.to_f

    glViewport(0, 0, fbWidth, fbHeight)
    glClearColor(0.8, 0.8, 0.8, 1.0)
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT|GL_STENCIL_BUFFER_BIT)

    hex_grid_layout.origin.x = fbWidth / 2.0
    hex_grid_layout.origin.y = fbHeight / 2.0

    nvgBeginFrame(vg, winWidth, winHeight, pxRatio)
    nvgSave(vg)

    n = 12
    nvgStrokeColor(vg, nvgRGBA(32, 64, 128, 255))
    nvgStrokeWidth(vg, 3.0)
    (-n..n).each do |q|
      (-n..n).each do |r|
        if q + r > n
          # r = n - q
          next
        elsif q + r < -n
          # r = -n - q
          next
        end
        h = Hex.new(q, r)
        corners = hex_grid_layout.polygon_corners(h)
        nvgBeginPath(vg)
        nvgMoveTo(vg, corners[0].x, corners[0].y)
        (1..5).each do |i|
          nvgLineTo(vg, corners[i].x, corners[i].y)
        end
        point = hex_grid_layout.hex_to_pixel(h)
        b = 64 * (point.x >= 0 ? point.x / fbWidth : 0)
        nvgClosePath(vg)
        gradient_start = nvgRGBA(164, 192, 192 + b, 255)
        gradient_end = nvgRGBA(224,255,255,255)
        paint = nvgLinearGradient(vg, point.x,point.y, point.x+n,point.y+n, gradient_start, gradient_end)
        nvgFillPaint(vg, paint)
        nvgFill(vg)
        nvgStroke(vg)
      end
    end
    nvgRestore(vg)
    nvgEndFrame(vg)

    glfwSwapBuffers( window )
    glfwPollEvents()
  end

  nvgDeleteGL2(vg)

  glfwTerminate()
end
