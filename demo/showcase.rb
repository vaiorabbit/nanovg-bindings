require_relative 'util/setup_dll'
require_relative 'util/setup_opengl_dll'
require_relative 'showcase/scenes'

$showcase = nil

# Press ESC to exit.
key = GLFW::create_callback(:GLFWkeyfun) do |window, key, scancode, action, mods|
  glfwSetWindowShouldClose(window, GL_TRUE) if key == GLFW_KEY_ESCAPE && action == GLFW_PRESS
  if key == GLFW_KEY_N && action == GLFW_PRESS
    $showcase.next_scene
    glfwSetWindowTitle(window, "Ruby-NanoVG : #{$showcase.scene_name}")
  end
  if key == GLFW_KEY_P && action == GLFW_PRESS
    $showcase.prev_scene
    glfwSetWindowTitle(window, "Ruby-NanoVG : #{$showcase.scene_name}")
  end
end

# Saves as .tga
$ss_name = "ss0000.tga"
$ss_id = 0
def save_screenshot(w, h, name)
  image = FFI::MemoryPointer.new(:uint8, w*h*4)
  return if image == nil

  glReadPixels(0, 0, w, h, GL_BGRA, GL_UNSIGNED_INT_8_8_8_8_REV, image)

  File.open( name, 'wb' ) do |fout|
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

if __FILE__ == $0
  prevt = 0.0

  glfwInit()

  glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 2)
  glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 0)

  window = glfwCreateWindow( 1000, 600, "NanoVG", nil, nil )

  glfwSetKeyCallback( window, key )
  glfwMakeContextCurrent( window )

  nvgSetupGL2()
  vg = nvgCreateGL2(NVG_ANTIALIAS | NVG_STENCIL_STROKES | NVG_DEBUG)

  $showcase = Showcase.new
  glfwSetWindowTitle(window, "Ruby-NanoVG : #{$showcase.scene_name}")

  glfwSwapInterval(0)
  glfwSetTime(0)
  prevt = glfwGetTime()

  mx_buf = '        '
  my_buf = '        '
  winWidth_buf  = '        '
  winHeight_buf = '        '
  fbWidth_buf  = '        '
  fbHeight_buf = '        '
  while glfwWindowShouldClose( window ) == 0
    t = glfwGetTime()
    dt = t - prevt
    prevt = t

    glfwGetCursorPos(window, mx_buf, my_buf)
    glfwGetWindowSize(window, winWidth_buf, winHeight_buf)
    glfwGetFramebufferSize(window, fbWidth_buf, fbHeight_buf)
    mx = mx_buf.unpack('D')[0]
    my = my_buf.unpack('D')[0]
    winWidth = winWidth_buf.unpack('L')[0]
    winHeight = winHeight_buf.unpack('L')[0]
    fbWidth = fbWidth_buf.unpack('L')[0]
    fbHeight = fbHeight_buf.unpack('L')[0]

    pxRatio = fbWidth.to_f / winWidth.to_f

    $showcase.set_viewport_size(fbWidth, fbHeight)

    glViewport(0, 0, fbWidth, fbHeight)
    glClearColor(0.3, 0.3, 0.32, 1.0)
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT|GL_STENCIL_BUFFER_BIT)

    nvgBeginFrame(vg, winWidth, winHeight, pxRatio)
    $showcase.render(vg, dt)
    nvgEndFrame(vg)

    glfwSwapBuffers( window )
    glfwPollEvents()

    # if $showcase.current_scene.should_save
    #   $ss_name = sprintf("ss%05d.tga", $ss_id)
    #   save_screenshot(fbWidth, fbHeight, $ss_name)
    #   $ss_id += 1
    #   $showcase.current_scene.should_save = false
    # end

  end

  nvgDeleteGL2(vg)

  glfwTerminate()
end
