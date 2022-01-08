# coding: utf-8
# Usage : $ ruby jpfont.rb [path to .ttf (ex.)./jpfont/GenShinGothic-Normal.ttf]

require_relative 'util/setup_dll'
require_relative 'util/setup_opengl_dll'

errorcb = GLFW::create_callback(:GLFWerrorfun) do |error, desc|
  printf("GLFW error %d: %s\n", error, desc)
end

# Press ESC to exit.
key = GLFW::create_callback(:GLFWkeyfun) do |window, key, scancode, action, mods|
  GLFW.SetWindowShouldClose(window, GL::TRUE) if key == GLFW::KEY_ESCAPE && action == GLFW::PRESS
end

$fonts = []

def font_load(vg, name="sans", ttf="./jpfont/GenShinGothic-Bold.ttf")
  font_handle = NVG.CreateFont(vg, name, ttf)
  if font_handle == -1
    puts "Could not add font."
    return -1
  end
  $fonts << font_handle
end

def draw_paragraph(vg, x, y, width, height, text, font_size=44.0, name="sans")
  rows_buf = FFI::MemoryPointer.new(NVG::TextRow, 3)
  glyphs_buf = FFI::MemoryPointer.new(NVG::GlyphPosition, 100)
  lineh_buf = ' ' * 8
  lineh = 0.0

  NVG.Save(vg)

  NVG.FontSize(vg, font_size)
  NVG.FontFace(vg, name)
  NVG.TextAlign(vg, NVG::ALIGN_LEFT|NVG::ALIGN_TOP)
  NVG.TextMetrics(vg, nil, nil, lineh_buf)
  lineh = lineh_buf.unpack('F')[0]

  text_start = text
  text_end = nil
  while ((nrows = NVG.TextBreakLines(vg, text_start, text_end, width, rows_buf, 3)))
    rows = nrows.times.collect do |i|
      NVG::TextRow.new(rows_buf + i * NVG::TextRow.size)
    end
    nrows.times do |i|
      row = rows[i]

      NVG.BeginPath(vg)
      NVG.FillColor(vg, NVG.RGBA(255,255,255, 0))
      NVG.Rect(vg, x, y, row[:width], lineh)
      NVG.Fill(vg)

      NVG.FillColor(vg, NVG.RGBA(255,255,255,255))
      NVG.Text(vg, x, y, row[:start], row[:end])

      y += lineh
    end
    if rows.length > 0
      text_start = rows[nrows-1][:next]
    else
      break
    end
  end

  NVG.Restore(vg)
end

if __FILE__ == $0

  GLFW.load_lib(SampleUtil.glfw_library_path)

  prevt = 0.0

  ttf = ARGV[0]

  if GLFW.Init() == GL::FALSE
    puts("Failed to init GLFW.")
    exit
  end

  GLFW.SetErrorCallback(errorcb)

  GLFW.WindowHint(GLFW::CONTEXT_VERSION_MAJOR, 2)
  GLFW.WindowHint(GLFW::CONTEXT_VERSION_MINOR, 0)

  window = GLFW.CreateWindow(800, 500, "Emoji(絵文字) on NanoVG", nil, nil)
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

  # font_load(vg, "sans", ttf == nil ? "./jpfont/GenShinGothic-Normal.ttf" : ttf)
  font_load(vg, "emoji", "./data/NotoEmoji-Regular.ttf")

  GLFW.SwapInterval(0)
  GLFW.SetTime(0)
  prevt = GLFW.GetTime()

  winWidth_buf  = ' ' * 8
  winHeight_buf = ' ' * 8
  fbWidth_buf  = ' ' * 8
  fbHeight_buf = ' ' * 8

  text = IO.read("./data/emojifont.txt", :encoding => "UTF-8")

  while GLFW.WindowShouldClose(window) == 0
    t = GLFW.GetTime()
    dt = t - prevt
    prevt = t

    GLFW.GetWindowSize(window, winWidth_buf, winHeight_buf)
    GLFW.GetFramebufferSize(window, fbWidth_buf, fbHeight_buf)
    winWidth = winWidth_buf.unpack('L')[0]
    winHeight = winHeight_buf.unpack('L')[0]
    fbWidth = fbWidth_buf.unpack('L')[0]
    fbHeight = fbHeight_buf.unpack('L')[0]

    pxRatio = fbWidth.to_f / winWidth.to_f

    GL.Viewport(0, 0, fbWidth, fbHeight)
    GL.ClearColor(0.3, 0.3, 0.32, 1.0)
    GL.Clear(GL::COLOR_BUFFER_BIT|GL::DEPTH_BUFFER_BIT|GL::STENCIL_BUFFER_BIT)

    NVG.BeginFrame(vg, winWidth, winHeight, pxRatio)

    draw_paragraph(vg, winWidth - 800, 10, 750, 500, text, 100.0, "emoji")
    NVG.EndFrame(vg)

    GLFW.SwapBuffers(window)
    GLFW.PollEvents()
  end

  NVG.DeleteGL2(vg)

  GLFW.Terminate()
end
