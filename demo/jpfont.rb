# coding: utf-8
# Usage : $ ruby jpfont.rb [path to .ttf (ex.)./jpfont/x12y16pxMaruMonica.ttf]
require_relative 'util/setup_dll'
require_relative 'util/setup_opengl_dll'

errorcb = GLFW::create_callback(:GLFWerrorfun) do |error, desc|
  printf("GLFW error %d: %s\n", error, desc)
end

# Press ESC to exit.
key = GLFW::create_callback(:GLFWkeyfun) do |window, key, scancode, action, mods|
  if key == GLFW::KEY_ESCAPE && action == GLFW::PRESS
    GLFW.SetWindowShouldClose(window, GL::TRUE)
  end
end

$fonts = []

def font_load(vg, name="sans", ttf="./jpfont/GenShinGothic-Bold.ttf")
  font_handle = nvgCreateFont(vg, name, ttf)
  if font_handle == -1
    puts "Could not add font."
    return -1
  end
  $fonts << font_handle
end

def draw_paragraph(vg, x, y, width, height, text, name="sans")
  rows_buf = FFI::MemoryPointer.new(NVGtextRow, 3)
  glyphs_buf = FFI::MemoryPointer.new(NVGglyphPosition, 100)
  lineh_buf = ' ' * 8
  lineh = 0.0

  nvgSave(vg)

  nvgFontSize(vg, 38.0)
  nvgFontFace(vg, name)
  nvgTextAlign(vg, NVG_ALIGN_LEFT|NVG_ALIGN_TOP)
  nvgTextMetrics(vg, nil, nil, lineh_buf)
  lineh = lineh_buf.unpack('F')[0]

  text_start = text
  text_end = nil
  while (nrows = nvgTextBreakLines(vg, text_start, text_end, width, rows_buf, 3))
    rows = nrows.times.collect do |i|
      NVGtextRow.new(rows_buf + i * NVGtextRow.size)
    end
    nrows.times do |i|
      row = rows[i]

      nvgBeginPath(vg)
      nvgFillColor(vg, nvgRGBA(255,255,255, 0))
      nvgRect(vg, x, y, row[:width], lineh)
      nvgFill(vg)

      nvgFillColor(vg, nvgRGBA(255,255,255,255))
      nvgText(vg, x, y, row[:start], row[:end])

      y += lineh
    end
    if rows.length > 0
      text_start = rows[nrows-1][:next]
    else
      break
    end
  end

  nvgRestore(vg)
end

if __FILE__ == $PROGRAM_NAME

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

  window = GLFW.CreateWindow(1280, 720, "日本語フォント on NanoVG", nil, nil)
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

  font_load(vg, "sans", ttf == nil ? "./jpfont/GenShinGothic-Normal.ttf" : ttf)

  GLFW.SwapInterval(0)
  GLFW.SetTime(0)
  prevt = GLFW.GetTime()

  winWidth_buf  = ' ' * 8
  winHeight_buf = ' ' * 8
  fbWidth_buf  = ' ' * 8
  fbHeight_buf = ' ' * 8

  text = IO.read("./jpfont/jpfont.txt", :encoding => "UTF-8")

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

    nvgBeginFrame(vg, winWidth, winHeight, pxRatio)

    draw_paragraph(vg, winWidth - 1200, 10, 1150, 700, text)
    nvgEndFrame(vg)

    GLFW.SwapBuffers(window)
    GLFW.PollEvents()
  end

  nvgDeleteGL2(vg)

  GLFW.Terminate()
end
