require_relative 'util/setup_dll'
require_relative 'util/setup_opengl_dll'
require_relative 'lib/hex'

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

  # Hex map rendering layout
  hex_grid_layout = Layout.new(Layout::FLAT, Point.new(28, 28), Point.new(1280/2.0, 720/2.0))

  # Hex map storage
  hex_map = [] # Set.new
  # Rectangular map loop for Layout::FLAT
  map_width = 30
  map_height = 14
  for q in 0...map_width
    q_offset = q >> 1 # (r / 2.0).floor
    for r in (-q_offset)...(map_height-q_offset)
      hex_map << Hex.new(q, r)
    end
  end
=begin
  # Rectangular map loop for Layout::POINTY
  map_width = 25
  map_height = 16
  for r in 0...map_height
    r_offset = r >> 1 # (r / 2.0).floor
    for q in (-r_offset)...(map_width-r_offset)
      hex_map << Hex.new(q, r)
    end
  end
=end

  hex_target = Hex.new(0, 0)

  hex_neighbors = [
    hex_target.neighbor(0),
    hex_target.neighbor(1),
    hex_target.neighbor(2),
    hex_target.neighbor(3),
    hex_target.neighbor(4),
    hex_target.neighbor(5),
  ]

  prevt = glfwGetTime()

  duration_threshold = 0.167
  current_duration = 0.0
  while glfwWindowShouldClose( window ) == 0
    t = glfwGetTime()
    dt = t - prevt
    prevt = t

    hex_neighbors = [
      hex_target.neighbor(0),
      hex_target.neighbor(1),
      hex_target.neighbor(2),
      hex_target.neighbor(3),
      hex_target.neighbor(4),
      hex_target.neighbor(5),
    ]

    # Wraparound
    hex_neighbors.each_with_index do |h, i|
      oc = OffsetCoord.qoffset_from_cube(OffsetCoord::ODD, h)
      wraparound = false
      if oc.col < 0 || oc.col >= map_width
        oc.col = (oc.col + map_width) % map_width
        wraparound = true
      end
      if oc.row < 0 || oc.row >= map_height
        oc.row = (oc.row + map_height) % map_height
        wraparound = true
      end
      hex_neighbors[i] = OffsetCoord.qoffset_to_cube(OffsetCoord::ODD, oc) if wraparound
    end

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

    hex_grid_layout.origin.x = hex_grid_layout.size.x * 1.1 #fbWidth / 2.0
    hex_grid_layout.origin.y = hex_grid_layout.size.y * 1.1 #fbHeight / 2.0

    nvgBeginFrame(vg, winWidth, winHeight, pxRatio)
    nvgSave(vg)

    nvgStrokeColor(vg, nvgRGBA(32, 64, 128, 255))
    nvgStrokeWidth(vg, 1.5)
    hex_map.each do |h|
      center = hex_grid_layout.hex_to_pixel(h)
      corners = hex_grid_layout.polygon_corners(h)
      corners = corners.collect {|corner|
        x = (corner.x - center.x) * 0.9 + center.x
        y = (corner.y - center.y) * 0.9 + center.y
        Point.new(x, y)
      }
      nvgBeginPath(vg)
      nvgMoveTo(vg, corners[0].x, corners[0].y)
      (1..5).each do |i|
        nvgLineTo(vg, corners[i].x, corners[i].y)
      end
      b = 64 * (center.x >= 0 ? center.x / fbWidth : 0)
      nvgClosePath(vg)
      neighbor = hex_neighbors.find {|neighbor| neighbor.q == h.q && neighbor.r == h.r}
      if h.q == hex_target.q and h.r == hex_target.r # target itself
        gradient_start = nvgRGBA(255, 64, 0, 255)
        gradient_end = nvgRGBA(224,255,255,255)
      elsif neighbor != nil # neighbor of target
        gradient_start = nvgRGBA(128, 255, 0, 255)
        gradient_end = nvgRGBA(224,255,255,255)
      else
        gradient_start = nvgRGBA(164, 180, 192 + b, 255)
        gradient_end = nvgRGBA(224,255,255,255)
      end
      paint = nvgLinearGradient(vg, center.x-10.0,center.y-10.0, center.x+10.0,center.y+10.0, gradient_start, gradient_end)
      nvgFillPaint(vg, paint)
      nvgFill(vg)
      nvgStroke(vg)
    end
    nvgRestore(vg)
    nvgEndFrame(vg)

    glfwSwapBuffers( window )
    glfwPollEvents()

    current_duration += dt
    if current_duration > duration_threshold
      current_index = hex_map.find_index{ |hex| hex.q == hex_target.q && hex.r == hex_target.r }
      next_index = (current_index + 1) % hex_map.length
      hex_target = hex_map[next_index]
      current_duration = 0.0
    end
  end

  nvgDeleteGL2(vg)

  glfwTerminate()
end
