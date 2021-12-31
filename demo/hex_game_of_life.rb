require_relative 'util/setup_dll'
require_relative 'util/setup_opengl_dll'
require_relative 'lib/hex'

class GOLHex < Hex
  attr_accessor :neighbors

  def initialize(q, r, s = -q - r)
    super(q, r, s)
    @neighbors = []
  end
end

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

  window = glfwCreateWindow( 1280, 720, "Game of Life in Hex Grid", nil, nil )
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
  hex_maps = [[], []]
  # Rectangular map loop for Layout::FLAT
  map_width = 30
  map_height = 14
  2.times do |i_map_index|
    for q in 0...map_width
      q_offset = q >> 1 # (r / 2.0).floor
      for r in (-q_offset)...(map_height-q_offset)
        hex_maps[i_map_index] << GOLHex.new(q, r)
      end
    end

    hex_maps[i_map_index].each_with_index do |hex, hi|
      6.times do |ni|
        hex_qrs = hex.neighbor_index(ni)
        oc_col, oc_row = OffsetCoord.qoffset_from_cube_coord(OffsetCoord::ODD, hex.q+hex_qrs[0], hex.r+hex_qrs[1])
        wraparound = false
        if oc_col < 0 || oc_col >= map_width
          oc_col = (oc_col + map_width) % map_width
          wraparound = true
        end
        if oc_row < 0 || oc_row >= map_height
          oc_row = (oc_row + map_height) % map_height
          wraparound = true
        end
        q, r, s = OffsetCoord.qoffset_to_cube_coord(OffsetCoord::ODD, oc_col, oc_row)
        hex_maps[i_map_index][hi].neighbors[ni] = hex_maps[i_map_index].find {|h| h.q == q && h.r == r && h.s == s}
      end
    end
  end

  current_hex_map_idx = 0
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

  #
  # Ref.: http://www.complex-systems.com/pdf/15-3-4.pdf
  #

  # Initial map : 3,5/2 hex glider
  alive_offsets = [
    [1, 4],
    [2, 3],
    [3, 1],
    [3, 4],
    [3, 6],
    [5, 1],
    [5, 4],
    [5, 6],
    [6, 3],
    [7, 4],
  ]
  hex_maps.each_with_index do |hm, hi|
    hm.each_with_index do |h, i|
      oc = OffsetCoord.qoffset_from_cube(OffsetCoord::ODD, h)
      ofs = alive_offsets.find {|of| oc.col == of[0] && oc.row == of[1]}
      hex_maps[hi][i].data = ofs != nil ? true : false
    end
  end
#pp hex_maps

  hex_map = hex_maps[current_hex_map_idx]
  hex_target = hex_map[0]

  prevt = glfwGetTime()

  duration_threshold = 1.0
  current_duration = 0.0
  while glfwWindowShouldClose( window ) == 0
    t = glfwGetTime()
    dt = t - prevt
    prevt = t

    # Render

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
      neighbor = hex_target.neighbors.find {|n| n.q == h.q && n.r == h.r}
      nvgBeginPath(vg)
      nvgMoveTo(vg, corners[0].x, corners[0].y)
      (1..5).each do |i|
        nvgLineTo(vg, corners[i].x, corners[i].y)
      end
      b = 64 * (center.x >= 0 ? center.x / fbWidth : 0)
      nvgClosePath(vg)

      if h.data == true
        gradient_start = nvgRGBA(0, 0, 0, 255)
        gradient_end = nvgRGBA(224,255,255,255)
      elsif h.q == hex_target.q and h.r == hex_target.r # target itself
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

      # Update : 3,5/2 hex glider
      hex_maps[1 - current_hex_map_idx].each do |hex|
        hex.data = false
      end

      hex_maps[current_hex_map_idx].each_with_index do |hex, idx|

        alive_cells_count = 0
        hex.neighbors.each {|n| alive_cells_count += 1 if n.data == true}

        hex_next = hex_maps[1 - current_hex_map_idx][idx]

        if alive_cells_count == 2 && hex.data == false
          hex_next.data = true
        elsif (alive_cells_count == 3 || alive_cells_count == 5) && hex.data == true
          hex_next.data = true
        end
      end

      # Swap map
      current_hex_map_idx = (current_hex_map_idx + 1) % hex_maps.length
      hex_map = hex_maps[current_hex_map_idx]

      current_index = hex_map.find_index{ |hex| hex.q == hex_target.q && hex.r == hex_target.r }
      next_index = (current_index + 1) % hex_map.length
      hex_target = hex_map[next_index]
      current_duration = 0.0
    end
  end

  nvgDeleteGL2(vg)

  glfwTerminate()
end
