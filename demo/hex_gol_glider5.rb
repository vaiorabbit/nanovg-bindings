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

MAP_DISP_STATE = [:render, :alpha_transit]
$state = :render

# Press ESC to exit.
key = GLFW::create_callback(:GLFWkeyfun) do |window, key, scancode, action, mods|
  if key == GLFW::KEY_ESCAPE && action == GLFW::PRESS
    GLFW.SetWindowShouldClose(window, GL::TRUE)
  end
end

if __FILE__ == $PROGRAM_NAME

  GLFW.load_lib(SampleUtil.glfw_library_path)

  if GLFW.Init() == GL::FALSE
    puts("Failed to init GLFW.")
    exit
  end

  GLFW.WindowHint(GLFW::CONTEXT_VERSION_MAJOR, 2)
  GLFW.WindowHint(GLFW::CONTEXT_VERSION_MINOR, 0)

  window = GLFW.CreateWindow(405, 720, "5-Step Glider Pattern for Hex Game of Life", nil, nil)
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

  winWidth_buf  = ' ' * 8
  winHeight_buf = ' ' * 8
  fbWidth_buf  = ' ' * 8
  fbHeight_buf = ' ' * 8

  # Hex map rendering layout
  hex_grid_layout = Layout.new(Layout::FLAT, Point.new(28, 28), Point.new(1280/2.0, 720/2.0))

  # Hex map storage
  hex_maps = [[], []]
  # Rectangular map loop for Layout::FLAT
  map_width = 9
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

  #
  # Ref.: http://www.complex-systems.com/pdf/15-3-4.pdf
  #

  # Initial map : 5-step glider pattern for 3,5/2 hex Game of Life
  alive_offsets = [
    [1, 10],
    [2, 9],
    [3, 7],
    [3, 10],
    [3, 12],
    [5, 7],
    [5, 10],
    [5, 12],
    [6, 9],
    [7, 10],
  ]
  hex_maps.each_with_index do |hm, hi|
    hm.each_with_index do |h, i|
      oc = OffsetCoord.qoffset_from_cube(OffsetCoord::ODD, h)
      ofs = alive_offsets.find {|of| oc.col == of[0] && oc.row == of[1]}
      hex_maps[hi][i].data = ofs != nil ? true : false
    end
  end

  hex_map = hex_maps[current_hex_map_idx]

  CELL_COLOR_ALIVE = nvgRGBA(20, 120, 220, 255)
  CELL_COLOR_EMPTY = nvgRGBA(164, 180, 224, 255)
  CELL_COLOR_END   = nvgRGBA(224,255,255,255)

  GLFW.SwapInterval(0)
  GLFW.SetTime(0)

  total_time = 0.0

  prevt = GLFW.GetTime()

  duration_threshold = 0.25
  current_duration = -3.0
  while GLFW.WindowShouldClose(window) == 0
    t = GLFW.GetTime()
    dt = 1.0 / 60.0 # t - prevt 
    prevt = t
    total_time += dt

    if total_time > 40.4 # Glider's time of arrival
      dt = 0.0
    end

    # Render

    GLFW.GetWindowSize(window, winWidth_buf, winHeight_buf)
    GLFW.GetFramebufferSize(window, fbWidth_buf, fbHeight_buf)
    winWidth = winWidth_buf.unpack('L')[0]
    winHeight = winHeight_buf.unpack('L')[0]
    fbWidth = fbWidth_buf.unpack('L')[0]
    fbHeight = fbHeight_buf.unpack('L')[0]

    pxRatio = fbWidth.to_f / winWidth.to_f

    GL.Viewport(0, 0, fbWidth, fbHeight)
    GL.ClearColor(0.8, 0.8, 0.8, 1.0)
    GL.Clear(GL::COLOR_BUFFER_BIT|GL::DEPTH_BUFFER_BIT|GL::STENCIL_BUFFER_BIT)

    hex_grid_layout.origin.x = hex_grid_layout.size.x * 1.1 #fbWidth / 2.0
    hex_grid_layout.origin.y = hex_grid_layout.size.y * 1.1 #fbHeight / 2.0

    nvgBeginFrame(vg, winWidth, winHeight, pxRatio)
    nvgSave(vg)

    nvgStrokeColor(vg, nvgRGBA(32, 64, 128, 255))
    nvgStrokeWidth(vg, 1.5)
    hex_map.each_with_index do |hex_current, hex_idx|
      # Draw edges
      center = hex_grid_layout.hex_to_pixel(hex_current)
      corners = hex_grid_layout.polygon_corners(hex_current)
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
      nvgClosePath(vg)

      # Select inner color
      gradient_start = hex_current.data == true ? CELL_COLOR_ALIVE : CELL_COLOR_EMPTY
      if $state == :alpha_transit # Need Alpha Fading into next map
        alpha_rate = [(current_duration / duration_threshold), 1.0].min # 0.0 - 1.0
        hex_next = hex_maps[1 - current_hex_map_idx][hex_idx]
        if hex_current.data != hex_next.data # Check dead -> alive or alive -> dead
          gradient_start_next = hex_next.data == true ? CELL_COLOR_ALIVE : CELL_COLOR_EMPTY
          gradient_start = nvgLerpRGBA(gradient_start, gradient_start_next, alpha_rate)
        end
      end
      paint = nvgLinearGradient(vg, center.x-10.0,center.y-10.0, center.x+10.0,center.y+10.0, gradient_start, CELL_COLOR_END)
      nvgFillPaint(vg, paint)
      nvgFill(vg) # Fill inner area

      nvgStroke(vg) # Fill edges
    end # hex_map.each_with_index do |hex_current, hex_idx|

    nvgRestore(vg)
    nvgEndFrame(vg)

    GLFW.SwapBuffers(window)
    GLFW.PollEvents()

    #
    # State Transition
    #
    current_duration += dt
    if current_duration > duration_threshold

      case $state
      when :render # On 'Render' to 'Alpha Transition'
        # Update next map by 3,5/2 hex Game of Life rule.
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
        $state = :alpha_transit

      when :alpha_transit # On 'Alpha Transition' to 'Render'
        # Swap map
        current_hex_map_idx = (current_hex_map_idx + 1) % hex_maps.length
        hex_map = hex_maps[current_hex_map_idx]
        $state = :render
      end

      current_duration = 0.0
    end

  end

  nvgDeleteGL2(vg)

  GLFW.Terminate()
end
