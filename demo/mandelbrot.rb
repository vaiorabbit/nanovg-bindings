# coding: utf-8
# Usage :
# $ ruby mandelbrot.rb [pixel_count]
require 'opengl'
require 'glfw'
require_relative '../lib/nanovg'

OpenGL.load_lib()
GLFW.load_lib()
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

$pixel_count = ARGV[0] == nil ? 100 : ARGV[0].to_i
$pixel_table = nil

if __FILE__ == $0

  if glfwInit() == GL_FALSE
    puts("Failed to init GLFW.")
    exit
  end

  glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 2)
  glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 0)

  window = glfwCreateWindow( 720, 720, "Mandelbrot set", nil, nil )
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

  $pixel_table = Array.new($pixel_count) { Array.new($pixel_count) { nil } }

  while glfwWindowShouldClose( window ) == 0

    glfwGetWindowSize(window, winWidth_buf, winHeight_buf)
    glfwGetFramebufferSize(window, fbWidth_buf, fbHeight_buf)
    winWidth = winWidth_buf.unpack('L')[0]
    winHeight = winHeight_buf.unpack('L')[0]
    fbWidth = fbWidth_buf.unpack('L')[0]
    fbHeight = fbHeight_buf.unpack('L')[0]

    pxRatio = fbWidth.to_f / winWidth.to_f

    glViewport(0, 0, fbWidth, fbHeight)
    glClearColor(0.1, 0.2, 0.3, 1.0)
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT|GL_STENCIL_BUFFER_BIT)

    nvgBeginFrame(vg, winWidth, winHeight, pxRatio)
    nvgSave(vg)

    cell_wh = 0.8 * [winWidth, winHeight].min / $pixel_count.to_f
    x_base = winWidth * 0.5  - (cell_wh * $pixel_count * 0.5) + cell_wh/2
    y_base = winHeight * 0.5 - (cell_wh * $pixel_count * 0.5) + cell_wh/2
    x = x_base
    y = y_base
    $pixel_count.times do |r|
      $pixel_count.times do |c|

        if $pixel_table[r][c] == nil
          x0 = (r - 0) * (1.0 - (-2.5)) / ($pixel_count.to_f - 0.0) + (-2.5)
          y0 = (c - 0) * (1.0 - (-1.0)) / ($pixel_count.to_f - 0.0) + (-1.0)
          xc = 0.0
          yc = 0.0
          iter = 0
          max_iter = 255
          while xc**2+yc**2 < 2*2 && iter < max_iter
            xtemp = xc**2 - yc**2 + x0
            yc = 2*xc*yc + y0
            xc = xtemp
            iter += 1
          end
          $pixel_table[r][c] = if iter < 4
                                 nvgRGBA(128,128,255, 255)
                               elsif iter < 8
                                 nvgRGBA(128,192,192, 255)
                               elsif iter < 12
                                 nvgRGBA(128,255,128, 255)
                               else
                                 nvgRGBA((max_iter-iter),(max_iter-iter),(max_iter-iter)/4, 255)
                               end
=begin
          if c > 0
            $pixel_table[r][c] = nvgLerpRGBA($pixel_table[r][c-1], $pixel_table[r][c], 0.5)
          elsif r > 0
            $pixel_table[r][c] = nvgLerpRGBA($pixel_table[r-1][c], $pixel_table[r][c], 0.5)
          end
=end
        end

        color = $pixel_table[r][c]
        nvgBeginPath(vg)
        nvgCircle(vg, x, y, cell_wh/2)
        paint = nvgRadialGradient(vg, x,y, 0.0,cell_wh/2, color, nvgRGBA(0,0,0,0))
        nvgFillPaint(vg, paint)
        nvgFill(vg)

        x += cell_wh
      end
      x = x_base
      y += cell_wh
    end

    nvgRestore(vg)
    nvgEndFrame(vg)

    glfwSwapBuffers( window )
    glfwPollEvents()
  end

  nvgDeleteGL2(vg)

  glfwTerminate()
end
