# coding: utf-8
# Usage : $ ruby jpfont.rb [path to .ttf (ex.)./jpfont/GenShinGothic-Normal.ttf]
require 'opengl'
require 'glfw'
require_relative '../nanovg'

OpenGL.load_dll()
GLFW.load_dll()
NanoVG.load_dll('libnanovg_gl2.dylib')

include OpenGL
include GLFW
include NanoVG

errorcb = GLFW::create_callback(:GLFWerrorfun) do |error, desc|
  printf("GLFW error %d: %s\n", error, desc)
end

# Press ESC to exit.
key = GLFW::create_callback(:GLFWkeyfun) do |window, key, scancode, action, mods|
  if key == GLFW_KEY_ESCAPE && action == GLFW_PRESS
    glfwSetWindowShouldClose(window, GL_TRUE)
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
  lineh_buf = '        '
  lineh = 0.0

  nvgSave(vg)

  nvgFontSize(vg, 44.0)
  nvgFontFace(vg, name)
  nvgTextAlign(vg, NVG_ALIGN_LEFT|NVG_ALIGN_TOP)
  nvgTextMetrics(vg, nil, nil, lineh_buf)
  lineh = lineh_buf.unpack('F')[0]

  text_start = text
  text_end = nil
  while ((nrows = nvgTextBreakLines(vg, text_start, text_end, width, rows_buf, 3)))
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

if __FILE__ == $0
  prevt = 0.0

  ttf = ARGV[0]

  if glfwInit() == GL_FALSE
    puts("Failed to init GLFW.")
    exit
  end

  glfwSetErrorCallback(errorcb)

  glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 2)
  glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 0)

  window = glfwCreateWindow( 1280, 720, "日本語フォント on NanoVG", nil, nil )
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

  font_load(vg, "sans", ttf == nil ? "./jpfont/GenShinGothic-Normal.ttf" : ttf)

  glfwSwapInterval(0)
  glfwSetTime(0)
  prevt = glfwGetTime()

  winWidth_buf  = '        '
  winHeight_buf = '        '
  fbWidth_buf  = '        '
  fbHeight_buf = '        '

  text = IO.read( "./jpfont/jpfont.txt", :encoding => "UTF-8" )

  while glfwWindowShouldClose( window ) == 0
    t = glfwGetTime()
    dt = t - prevt
    prevt = t

    glfwGetWindowSize(window, winWidth_buf, winHeight_buf)
    glfwGetFramebufferSize(window, fbWidth_buf, fbHeight_buf)
    winWidth = winWidth_buf.unpack('L')[0]
    winHeight = winHeight_buf.unpack('L')[0]
    fbWidth = fbWidth_buf.unpack('L')[0]
    fbHeight = fbHeight_buf.unpack('L')[0]

    pxRatio = fbWidth.to_f / winWidth.to_f

    glViewport(0, 0, fbWidth, fbHeight)
    glClearColor(0.3, 0.3, 0.32, 1.0)
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT|GL_STENCIL_BUFFER_BIT)

    nvgBeginFrame(vg, winWidth, winHeight, pxRatio)

    draw_paragraph(vg, winWidth - 1200, 10, 1150, 700, text)
    nvgEndFrame(vg)

    glfwSwapBuffers( window )
    glfwPollEvents()
  end

  nvgDeleteGL2(vg)

  glfwTerminate()
end
