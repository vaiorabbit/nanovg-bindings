require_relative 'util/setup_dll'
require_relative 'util/setup_opengl_dll'
require_relative 'lib/hex'

# Press ESC to exit.
key = GLFW::create_callback(:GLFWkeyfun) do |window, key, scancode, action, mods|
  GLFW.SetWindowShouldClose(window, GL::TRUE) if key == GLFW::KEY_ESCAPE && action == GLFW::PRESS
end

if __FILE__ == $PROGRAM_NAME

  GLFW.load_lib(SampleUtil.glfw_library_path)

  if GLFW.Init() == GL::FALSE
    puts("Failed to init GLFW.")
    exit
  end

  GLFW.WindowHint(GLFW::CONTEXT_VERSION_MAJOR, 2)
  GLFW.WindowHint(GLFW::CONTEXT_VERSION_MINOR, 0)

  window = GLFW.CreateWindow(1280, 720, "Hex Grid Renderer", nil, nil)
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

  GLFW.SwapInterval(0)
  GLFW.SetTime(0)

  winWidth_buf  = ' ' * 8
  winHeight_buf = ' ' * 8
  fbWidth_buf  = ' ' * 8
  fbHeight_buf = ' ' * 8

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

  prevt = GLFW.GetTime()

  duration_threshold = 0.167
  current_duration = 0.0
  while GLFW.WindowShouldClose(window) == 0
    t = GLFW.GetTime()
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

    NVG.BeginFrame(vg, winWidth, winHeight, pxRatio)
    NVG.Save(vg)

    NVG.StrokeColor(vg, NVG.RGBA(32, 64, 128, 255))
    NVG.StrokeWidth(vg, 1.5)
    hex_map.each do |h|
      center = hex_grid_layout.hex_to_pixel(h)
      corners = hex_grid_layout.polygon_corners(h)
      corners = corners.collect {|corner|
        x = (corner.x - center.x) * 0.9 + center.x
        y = (corner.y - center.y) * 0.9 + center.y
        Point.new(x, y)
      }
      NVG.BeginPath(vg)
      NVG.MoveTo(vg, corners[0].x, corners[0].y)
      (1..5).each do |i|
        NVG.LineTo(vg, corners[i].x, corners[i].y)
      end
      b = 64 * (center.x >= 0 ? center.x / fbWidth : 0)
      NVG.ClosePath(vg)
      neighbor = hex_neighbors.find {|neighbor| neighbor.q == h.q && neighbor.r == h.r}
      if h.q == hex_target.q and h.r == hex_target.r # target itself
        gradient_start = NVG.RGBA(255, 64, 0, 255)
        gradient_end = NVG.RGBA(224,255,255,255)
      elsif neighbor != nil # neighbor of target
        gradient_start = NVG.RGBA(128, 255, 0, 255)
        gradient_end = NVG.RGBA(224,255,255,255)
      else
        gradient_start = NVG.RGBA(164, 180, 192 + b, 255)
        gradient_end = NVG.RGBA(224,255,255,255)
      end
      paint = NVG.LinearGradient(vg, center.x-10.0,center.y-10.0, center.x+10.0,center.y+10.0, gradient_start, gradient_end)
      NVG.FillPaint(vg, paint)
      NVG.Fill(vg)
      NVG.Stroke(vg)
    end
    NVG.Restore(vg)
    NVG.EndFrame(vg)

    GLFW.SwapBuffers(window)
    GLFW.PollEvents()

    current_duration += dt
    if current_duration > duration_threshold
      current_index = hex_map.find_index{ |hex| hex.q == hex_target.q && hex.r == hex_target.r }
      next_index = (current_index + 1) % hex_map.length
      hex_target = hex_map[next_index]
      current_duration = 0.0
    end
  end

  NVG.DeleteGL2(vg)

  GLFW.Terminate()
end
