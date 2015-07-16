# coding: utf-8
# Usage :
# $ gem install rqrcode
# $ ruby qrc.rb [String to encode into QR code]
require 'rqrcode'
require 'opengl'
require 'glfw'
require_relative '../nanovg'

OpenGL.load_dll()
GLFW.load_dll()
NanoVG.load_dll('libnanovg_gl2.dylib')

include RQRCode
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
  text = ARGV[0]
  text = "https://github.com/vaiorabbit/nanovg-bindings" if text == nil

  if glfwInit() == GL_FALSE
    puts("Failed to init GLFW.")
    exit
  end

  glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 2)
  glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 0)

  window = glfwCreateWindow( 1280, 720, "QRCode on NanoVG (Powered by RQRCode)", nil, nil )
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

  qrc = QRCode.new(text)
  while glfwWindowShouldClose( window ) == 0

    glfwGetWindowSize(window, winWidth_buf, winHeight_buf)
    glfwGetFramebufferSize(window, fbWidth_buf, fbHeight_buf)
    winWidth = winWidth_buf.unpack('L')[0]
    winHeight = winHeight_buf.unpack('L')[0]
    fbWidth = fbWidth_buf.unpack('L')[0]
    fbHeight = fbHeight_buf.unpack('L')[0]

    pxRatio = fbWidth.to_f / winWidth.to_f

    glViewport(0, 0, fbWidth, fbHeight)
    glClearColor(1.0, 1.0, 1.0, 1.0)
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT|GL_STENCIL_BUFFER_BIT)

    nvgBeginFrame(vg, winWidth, winHeight, pxRatio)
    nvgSave(vg)

    cell_wh = 0.8 * [winWidth, winHeight].min / qrc.modules.size.to_f
    x_base = winWidth * 0.5  - (cell_wh * qrc.modules.size * 0.5)
    y_base = winHeight * 0.5 - (cell_wh * qrc.modules.size * 0.5)
    x = x_base
    y = y_base
    qrc.modules.each_index do |r|
      qrc.modules.each_index do |c|
        color = qrc.is_dark(r, c) ? nvgRGBA(0,0,0, 255) : nvgRGBA(255,255,255, 255)
        nvgBeginPath(vg)
        nvgFillColor(vg, color)
        nvgRect(vg, x, y, cell_wh, cell_wh)
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

  # puts qrc.to_s(:true => '■', :false => '□')
end
