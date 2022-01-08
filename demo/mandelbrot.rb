# coding: utf-8
# Usage :
# $ ruby mandelbrot.rb [pixel_count]
require_relative 'util/setup_dll'
require_relative 'util/setup_opengl_dll'

# Press ESC to exit.
key = GLFW::create_callback(:GLFWkeyfun) do |window, key, scancode, action, mods|
  GLFW.SetWindowShouldClose(window, GL::TRUE) if key == GLFW::KEY_ESCAPE && action == GLFW::PRESS
end

$pixel_count = ARGV[0]&.to_i || 100
$pixel_table = nil

if __FILE__ == $PROGRAM_NAME

  GLFW.load_lib(SampleUtil.glfw_library_path)

  if GLFW.Init() == GL::FALSE
    puts("Failed to init GLFW.")
    exit
  end

  GLFW.WindowHint(GLFW::CONTEXT_VERSION_MAJOR, 2)
  GLFW.WindowHint(GLFW::CONTEXT_VERSION_MINOR, 0)

  window = GLFW.CreateWindow(720, 720, "Mandelbrot set", nil, nil)
  if window == 0
    GLFW.Terminate()
    exit
  end

  GLFW.SetKeyCallback(window, key)

  GLFW.MakeContextCurrent(window)

  GL.load_lib()

  NVG.SetupGL2()
  vg = NVG.CreateGL2(NVG::ANTIALIAS | NVG::STENCIL_STROKES | NVG::DEBUG)
  if vg == nil
    puts("Could not init nanovg.")
    exit
  end

  GLFW.SwapInterval(0)
  GLFW.SetTime(0)

  winWidth_buf  = ' ' * 8
  winHeight_buf = ' ' * 8
  fbWidth_buf  = ' ' * 8
  fbHeight_buf = ' ' * 8

  $pixel_table = Array.new($pixel_count) { Array.new($pixel_count) { nil } }

  while GLFW.WindowShouldClose(window) == 0

    GLFW.GetWindowSize(window, winWidth_buf, winHeight_buf)
    GLFW.GetFramebufferSize(window, fbWidth_buf, fbHeight_buf)
    winWidth = winWidth_buf.unpack('L')[0]
    winHeight = winHeight_buf.unpack('L')[0]
    fbWidth = fbWidth_buf.unpack('L')[0]
    fbHeight = fbHeight_buf.unpack('L')[0]

    pxRatio = fbWidth.to_f / winWidth.to_f

    GL.Viewport(0, 0, fbWidth, fbHeight)
    GL.ClearColor(0.1, 0.2, 0.3, 1.0)
    GL.Clear(GL::COLOR_BUFFER_BIT|GL::DEPTH_BUFFER_BIT|GL::STENCIL_BUFFER_BIT)

    NVG.BeginFrame(vg, winWidth, winHeight, pxRatio)
    NVG.Save(vg)

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
                                 NVG.RGBA(128,128,255, 255)
                               elsif iter < 8
                                 NVG.RGBA(128,192,192, 255)
                               elsif iter < 12
                                 NVG.RGBA(128,255,128, 255)
                               else
                                 NVG.RGBA((max_iter-iter),(max_iter-iter),(max_iter-iter)/4, 255)
                               end
=begin
           if c > 0
             $pixel_table[r][c] = NVG.LerpRGBA($pixel_table[r][c-1], $pixel_table[r][c], 0.5)
           elsif r > 0
             $pixel_table[r][c] = NVG.LerpRGBA($pixel_table[r-1][c], $pixel_table[r][c], 0.5)
           end
=end
        end

        color = $pixel_table[r][c]
        NVG.BeginPath(vg)
        NVG.Circle(vg, x, y, cell_wh/2)
        paint = NVG.RadialGradient(vg, x,y, 0.0,cell_wh/2, color, NVG.RGBA(0,0,0,0))
        NVG.FillPaint(vg, paint)
        NVG.Fill(vg)

        x += cell_wh
      end
      x = x_base
      y += cell_wh
    end

    NVG.Restore(vg)
    NVG.EndFrame(vg)

    GLFW.SwapBuffers(window)
    GLFW.PollEvents()
  end

  NVG.DeleteGL2(vg)

  GLFW.Terminate()
end
