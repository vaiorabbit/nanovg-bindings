# Usage :
# $ gem install rqrcode
# $ ruby qrc.rb [String to encode into QR code]
require 'rqrcode'
require_relative 'util/setup_dll'
require_relative 'util/setup_opengl_dll'

include RQRCode

# Press ESC to exit.
key = GLFW::create_callback(:GLFWkeyfun) do |window, key, scancode, action, mods|
  GLFW.SetWindowShouldClose(window, GL::TRUE) if key == GLFW::KEY_ESCAPE && action == GLFW::PRESS
end

if __FILE__ == $PROGRAM_NAME

  GLFW.load_lib(SampleUtil.glfw_library_path)

  text = ARGV[0]
  text = "https://github.com/vaiorabbit/nanovg-bindings" if text == nil

  if GLFW.Init() == GL::FALSE
    puts("Failed to init GLFW.")
    exit
  end

  GLFW.WindowHint(GLFW::CONTEXT_VERSION_MAJOR, 2)
  GLFW.WindowHint(GLFW::CONTEXT_VERSION_MINOR, 0)

  window = GLFW.CreateWindow(1280, 720, "QRCode on NanoVG (Powered by RQRCode)", nil, nil)
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

  GLFW.SwapInterval(0)
  GLFW.SetTime(0)

  winWidth_buf  = ' ' * 8
  winHeight_buf = ' ' * 8
  fbWidth_buf  = ' ' * 8
  fbHeight_buf = ' ' * 8

  qrc = QRCode.new(text)
  while GLFW.WindowShouldClose(window) == 0

    GLFW.GetWindowSize(window, winWidth_buf, winHeight_buf)
    GLFW.GetFramebufferSize(window, fbWidth_buf, fbHeight_buf)
    winWidth = winWidth_buf.unpack('L')[0]
    winHeight = winHeight_buf.unpack('L')[0]
    fbWidth = fbWidth_buf.unpack('L')[0]
    fbHeight = fbHeight_buf.unpack('L')[0]

    pxRatio = fbWidth.to_f / winWidth.to_f

    GL.Viewport(0, 0, fbWidth, fbHeight)
    GL.ClearColor(1.0, 1.0, 1.0, 1.0)
    GL.Clear(GL::COLOR_BUFFER_BIT|GL::DEPTH_BUFFER_BIT|GL::STENCIL_BUFFER_BIT)

    nvgBeginFrame(vg, winWidth, winHeight, pxRatio)
    nvgSave(vg)

    cell_wh = 0.8 * [winWidth, winHeight].min / qrc.modules.size.to_f
    x_base = winWidth * 0.5  - (cell_wh * qrc.modules.size * 0.5)
    y_base = winHeight * 0.5 - (cell_wh * qrc.modules.size * 0.5)
    x = x_base
    y = y_base
    qrc.modules.each_index do |r|
      qrc.modules.each_index do |c|
        color = qrc.qrcode.checked?(r, c) ? nvgRGBA(0,0,0, 255) : nvgRGBA(255,255,255, 255)
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

    GLFW.SwapBuffers(window)
    GLFW.PollEvents()
  end

  nvgDeleteGL2(vg)

  GLFW.Terminate()

end
