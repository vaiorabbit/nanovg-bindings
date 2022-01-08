require_relative 'util/setup_dll'
require_relative 'util/setup_opengl_dll'
require_relative 'showcase/scenes'

$showcase = nil

# Press ESC to exit.
key = GLFW::create_callback(:GLFWkeyfun) do |window, key, scancode, action, mods|
  GLFW.SetWindowShouldClose(window, GL::TRUE) if key == GLFW::KEY_ESCAPE && action == GLFW::PRESS
  if key == GLFW::KEY_N && action == GLFW::PRESS
    $showcase.next_scene
    GLFW.SetWindowTitle(window, "Ruby-NanoVG : #{$showcase.scene_name}")
  end
  if key == GLFW::KEY_P && action == GLFW::PRESS
    $showcase.prev_scene
    GLFW.SetWindowTitle(window, "Ruby-NanoVG : #{$showcase.scene_name}")
  end
end

# Saves as .tga
$ss_name = "ss0000.tga"
$ss_id = 0
def save_screenshot(w, h, name)
  image = FFI::MemoryPointer.new(:uint8, w*h*4)
  return if image == nil

  GL.ReadPixels(0, 0, w, h, GL::BGRA, GL::UNSIGNED_INT_8_8_8_8_REV, image)

  File.open(name, 'wb') do |fout|
    fout.write [0].pack('c')      # identsize
    fout.write [0].pack('c')      # colourmaptype
    fout.write [2].pack('c')      # imagetype
    fout.write [0].pack('s')      # colourmapstart
    fout.write [0].pack('s')      # colourmaplength
    fout.write [0].pack('c')      # colourmapbits
    fout.write [0].pack('s')      # xstart
    fout.write [0].pack('s')      # ystart
    fout.write [w].pack('s')      # image_width
    fout.write [h].pack('s')      # image_height
    fout.write [8 * 4].pack('c')  # image_bits_per_pixel
    fout.write [8].pack('c')      # descriptor

    fout.write image.get_bytes(0, w*h*4)
  end
end

if __FILE__ == $PROGRAM_NAME

  GLFW.load_lib(SampleUtil.glfw_library_path)

  prevt = 0.0

  GLFW.Init()

  GLFW.WindowHint(GLFW::CONTEXT_VERSION_MAJOR, 2)
  GLFW.WindowHint(GLFW::CONTEXT_VERSION_MINOR, 0)

  window = GLFW.CreateWindow(1000, 600, "NanoVG", nil, nil)

  GLFW.SetKeyCallback(window, key)
  GLFW.MakeContextCurrent(window)

  GL.load_lib()

  NVG.SetupGL2()
  vg = NVG.CreateGL2(NVG::ANTIALIAS | NVG::STENCIL_STROKES | NVG::DEBUG)

  $showcase = Showcase.new
  GLFW.SetWindowTitle(window, "Ruby-NanoVG : #{$showcase.scene_name}")

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

    $showcase.set_viewport_size(fbWidth, fbHeight)

    GL.Viewport(0, 0, fbWidth, fbHeight)
    GL.ClearColor(0.3, 0.3, 0.32, 1.0)
    GL.Clear(GL::COLOR_BUFFER_BIT|GL::DEPTH_BUFFER_BIT|GL::STENCIL_BUFFER_BIT)

    NVG.BeginFrame(vg, winWidth, winHeight, pxRatio)
    $showcase.render(vg, dt)
    NVG.EndFrame(vg)

    GLFW.SwapBuffers(window)
    GLFW.PollEvents()

    # if $showcase.current_scene.should_save
    #   $ss_name = sprintf("ss%05d.tga", $ss_id)
    #   save_screenshot(fbWidth, fbHeight, $ss_name)
    #   $ss_id += 1
    #   $showcase.current_scene.should_save = false
    # end

  end

  NVG.DeleteGL2(vg)

  GLFW.Terminate()
end
