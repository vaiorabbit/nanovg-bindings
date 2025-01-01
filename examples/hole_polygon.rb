# coding: utf-8
# Usage:
# $ gem install rmath3d_plain
# $ ruby hole_polygon.rb
require 'rmath3d/rmath3d_plain'
require_relative 'util/setup_dll'
require_relative 'util/setup_opengl_dll'
require_relative 'geom/convex_partitioning'
require_relative 'geom/segment_intersection'

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

class FontPlane
  def initialize
    @fonts = []
  end

  def load(vg, name="sans", ttf="./jpfont/GenShinGothic-Bold.ttf")
    font_handle = NVG.CreateFont(vg, name, ttf)
    if font_handle == -1
      puts "Could not add font."
      return -1
    end
    @fonts << font_handle
  end

  def render(vg, x, y, width, height, text, name: "sans", color: NVG.RGBA(255,255,255,255))
    rows_buf = FFI::MemoryPointer.new(NVG::TextRow, 3)
    glyphs_buf = FFI::MemoryPointer.new(NVG::GlyphPosition, 100)
    lineh_buf = ' ' * 8
    lineh = 0.0

    NVG.Save(vg)

    NVG.FontSize(vg, 44.0)
    NVG.FontFace(vg, name)
    NVG.TextAlign(vg, NVG::ALIGN_LEFT|NVG::ALIGN_TOP)
    NVG.TextMetrics(vg, nil, nil, lineh_buf)
    lineh = lineh_buf.unpack('F')[0]

    text_start = text
    text_end = nil
    while ((nrows = NVG.TextBreakLines(vg, text_start, text_end, width, rows_buf, 3)))
      rows = nrows.times.collect do |i|
        NVG::TextRow.new(rows_buf + i * NVG::TextRow.size)
      end
      nrows.times do |i|
        row = rows[i]

        NVG.BeginPath(vg)
#        NVG.FillColor(vg, NVG.RGBA(255,255,255, 0))
#        NVG.Rect(vg, x, y, row[:width], lineh)
#        NVG.Fill(vg)

        NVG.FillColor(vg, color)
        NVG.Text(vg, x, y, row[:start], row[:end])

        y += lineh
      end
      if rows.length > 0
        text_start = rows[nrows-1][:next]
      else
        break
      end
    end

    NVG.Restore(vg)
  end
end

class Graph
  attr_accessor :nodes, :triangle_indices

  def initialize
    @nodes = []
    @undo_insert_index = -1
    @node_radius = 10.0

    @triangle_indices = []
    @hull_indices = []
  end

  def add_node(x, y)
    @nodes << RVec2.new(x, y)
  end

  def insert_node(point_x, point_y)
    if @nodes.length < 3
      add_node(point_x, point_y)
      if @nodes.length == 3 && Triangle.ccw(@nodes[0], @nodes[1], @nodes[2]) > 0
        @nodes[1], @nodes[2] = @nodes[2], @nodes[1]
      end
      return
    end
    point = RVec2.new(point_x, point_y)

    # Calculate distance from point to all edges.
    # Ref. : http://stackoverflow.com/questions/849211/shortest-distance-between-a-point-and-a-line-segment
    distances = Array.new(@nodes.length) { -Float::MAX }
    @nodes.each_with_index do |node_current, index|
      node_next = @nodes[(index + 1) % @nodes.length]
      edge_dir = node_next - node_current
      edge_squared_length = edge_dir.getLengthSq
      if edge_squared_length < Float::EPSILON
        distances[index] = (node_current - point).getLength
        next
      end
      edge_start_to_point = point - node_current
      t = RVec2.dot(edge_start_to_point, edge_dir) / edge_squared_length
      if t < 0
        distances[index] = (node_current - point).getLength
      elsif t > 1
        distances[index] = (node_next - point).getLength
      else
        projection = node_current + t * edge_dir
        distances[index] = (projection - point).getLength
      end
    end

    # Find nearest edge and insert new Node as a dividing point.
    segment_indices = []
    @nodes.length.times do |i|
      segment_indices << [i, (i + 1) % @nodes.length]
    end

    minimum_distances = distances.min_by(2) {|d| d}
    nearest_edge_index = -1
    if minimum_distances[0] != minimum_distances[1]
      i = distances.find_index(minimum_distances[0])
      edge_node_indices = segment_indices.select { |segment_index| segment_index.include?(i) }
      e0_self_intersect = SegmentIntersection.check(@nodes + [point], segment_indices - [edge_node_indices[0]] + [[edge_node_indices[0][0], @nodes.length], [@nodes.length, edge_node_indices[0][1]]])
      e1_self_intersect = SegmentIntersection.check(@nodes + [point], segment_indices - [edge_node_indices[1]] + [[edge_node_indices[1][0], @nodes.length], [@nodes.length, edge_node_indices[1][1]]])
      if e0_self_intersect && e1_self_intersect
        nearest_edge_index = -1
      elsif e0_self_intersect
        nearest_edge_index = edge_node_indices[1][0]
      elsif e1_self_intersect
        nearest_edge_index = edge_node_indices[0][0]
      else
        nearest_edge_index = i
      end

    end

    if nearest_edge_index == -1

      distances = Array.new(@nodes.length) { -Float::MAX }
      @nodes.each_with_index do |node_current, index|
        distances[index] = (node_current - point).getLength
      end
      distances.sort.each do |d|
        i = distances.find_index(d)
        edge_node_indices = segment_indices.select { |segment_index| segment_index.include?(i) }
        e0_self_intersect = SegmentIntersection.check(@nodes + [point], segment_indices - [edge_node_indices[0]] + [[edge_node_indices[0][0], @nodes.length], [@nodes.length, edge_node_indices[0][1]]])
        e1_self_intersect = SegmentIntersection.check(@nodes + [point], segment_indices - [edge_node_indices[1]] + [[edge_node_indices[1][0], @nodes.length], [@nodes.length, edge_node_indices[1][1]]])
        if e0_self_intersect && e1_self_intersect
          next
        elsif e0_self_intersect
          nearest_edge_index = edge_node_indices[1][0]
          break
        elsif e1_self_intersect
          nearest_edge_index = edge_node_indices[0][0]
          break
        else
          nearest_edge_index = i
          break
        end
      end
    end

    if nearest_edge_index == -1
      puts "fail"
      return
    end

    @nodes.insert(nearest_edge_index + 1, RVec2.new(point_x, point_y))
    @undo_insert_index = nearest_edge_index + 1
  end

  def undo_insert
    if @undo_insert_index >= 0
      @nodes.delete_at(@undo_insert_index)
      @undo_insert_index = -1
      if $outer_graph.nodes.length <= 2
        $outer_graph.clear
      else
        $outer_graph.triangulate
      end
    end
  end

  def node_removable?(node_index)
    segment_indices = []
    new_edge_index = []
    @nodes.length.times do |i|
      if i == node_index 
        new_edge_index << (i + 1) % @nodes.length
        next
      end
      if (i + 1) % @nodes.length == node_index
        new_edge_index << i
        next
      end
      segment_indices << [i, (i + 1) % @nodes.length]
    end
    return SegmentIntersection.check(@nodes, segment_indices + [new_edge_index]) == false
  end

  def remove_nearest_node(point_x, point_y)
    distances = Array.new(@nodes.length) { -Float::MAX }
    @nodes.each_with_index do |node_current, index|
      distances[index] = (node_current.x - point_x)**2 + (node_current.y - point_y)**2
    end
    minimum_distance = distances.min_by {|d| d}
    if minimum_distance <= @node_radius ** 2
      nearest_node_index = distances.find_index(minimum_distance)
      @undo_insert_index = -1
      if node_removable?(nearest_node_index)
        @nodes.delete_at(nearest_node_index)
      else
        puts "[WARN] remove_nearest_node : Failed. Removing the node #{nearest_node_index} will make self-intersecting polygon."
      end
    end
  end

  def triangulate
    return if @nodes.length < 3
    @triangle_indices = ConvexPartitioning.triangulate(@nodes)
  end

  def clear
    @nodes.clear
    @triangle_indices.clear if @triangle_indices != nil
  end

  def render(vg, render_edge: true, render_node: true, color_scheme: :outer)
    # Triangles
    if @triangle_indices.length > 0
      color = NVG.RGBA(0,255,0, 255)
      lw = @node_radius * 0.5
      @triangle_indices.each do |indices|
        NVG.LineCap(vg, NVG::ROUND)
        NVG.LineJoin(vg, NVG::ROUND)
        NVG.BeginPath(vg)
        NVG.MoveTo(vg, @nodes[indices[0]].x, @nodes[indices[0]].y)
        NVG.LineTo(vg, @nodes[indices[1]].x, @nodes[indices[1]].y)
        NVG.LineTo(vg, @nodes[indices[2]].x, @nodes[indices[2]].y)
        NVG.ClosePath(vg)
        color = NVG.RGBA(0,255,0, 64)
        NVG.FillColor(vg, color)
        NVG.Fill(vg)
        color = NVG.RGBA(255,128,0, 255)
        NVG.StrokeColor(vg, color)
        NVG.StrokeWidth(vg, lw)
        NVG.Stroke(vg)
      end
    end

    # Edges
    if render_edge and @nodes.length >= 2
      color = color_scheme == :outer ? NVG.RGBA(0,0,255, 255) : NVG.RGBA(255,0,0, 255)
      lw = @node_radius * 0.5
      NVG.LineCap(vg, NVG::ROUND)
      NVG.LineJoin(vg, NVG::ROUND)
      NVG.BeginPath(vg)
      @nodes.length.times do |i|
        if i == 0
          NVG.MoveTo(vg, @nodes[0].x, @nodes[0].y)
        else
          NVG.LineTo(vg, @nodes[i].x, @nodes[i].y)
        end
      end
      NVG.ClosePath(vg)
      NVG.StrokeColor(vg, color)
      NVG.StrokeWidth(vg, lw)
      NVG.Stroke(vg)
    end

    # Nodes
    if render_node and @nodes.length > 0
      color = color_scheme == :outer ? NVG.RGBA(0,192,255, 255) : NVG.RGBA(255,192,0, 255)
      NVG.BeginPath(vg)
      @nodes.each do |node|
        NVG.Circle(vg, node.x, node.y, @node_radius)
        NVG.FillColor(vg, color)
      end
      NVG.Fill(vg)
    end

  end
end

$font_plane = FontPlane.new

$outer_graph = Graph.new
$inner_graph = Graph.new
$current_graph = $outer_graph

key = GLFW::create_callback(:GLFWkeyfun) do |window, key, scancode, action, mods|
  if key == GLFW::KEY_ESCAPE && action == GLFW::PRESS # Press ESC to exit.
    GLFW.SetWindowShouldClose(window, GL::TRUE)
  elsif key == GLFW::KEY_SPACE && action == GLFW::PRESS
    $current_graph = $current_graph == $inner_graph ? $outer_graph : $inner_graph
  elsif key == GLFW::KEY_R && action == GLFW::PRESS # Press 'R' to clear graph.
    $current_graph.clear
  elsif key == GLFW::KEY_M && action == GLFW::PRESS # Press 'M' to merge inner polygon.
    $outer_graph.nodes = ConvexPartitioning.merge_inner_polygon($outer_graph.nodes, $inner_graph.nodes)
    $outer_graph.triangulate
  elsif key == GLFW::KEY_Z && action == GLFW::PRESS && (mods & GLFW::MOD_CONTROL != 0) # Remove the last node your added by Ctrl-Z.
    $current_graph.undo_insert
  end
end

mouse = GLFW::create_callback(:GLFWmousebuttonfun) do |window_handle, button, action, mods|
  if button == GLFW::MOUSE_BUTTON_LEFT && action == 0
    mx_buf = ' ' * 8
    my_buf = ' ' * 8
    GLFW.GetCursorPos(window_handle, mx_buf, my_buf)
    mx = mx_buf.unpack('D')[0]
    my = my_buf.unpack('D')[0]
    if (mods & GLFW::MOD_SHIFT) != 0
      $current_graph.remove_nearest_node(mx, my)
      if $current_graph.nodes.length <= 2
        $current_graph.clear
      else
        $current_graph.triangulate
      end
    else
      $current_graph.insert_node(mx, my) # add_node(mx, my)
      $current_graph.triangulate
    end
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
  GLFW.DefaultWindowHints()

  window = GLFW.CreateWindow(1280, 720, "Triangulation", nil, nil)
  if window == 0
    GLFW.Terminate()
    exit
  end

  GLFW.SetKeyCallback(window, key)
  GLFW.SetMouseButtonCallback(window, mouse)

  GLFW.MakeContextCurrent(window)

  GL.load_lib()

  NVG.SetupGL2()
  vg = NVG.CreateGL2(NVG::ANTIALIAS | NVG::STENCIL_STROKES)
  if vg == nil
    puts("Could not init nanovg.")
    exit
  end

  winWidth_buf  = ' ' * 8
  winHeight_buf = ' ' * 8
  fbWidth_buf  = ' ' * 8
  fbHeight_buf = ' ' * 8

  $font_plane.load(vg, "sans", "./jpfont/GenShinGothic-Normal.ttf")

  GLFW.SwapInterval(0)
  GLFW.SetTime(0)

  total_time = 0.0

  prevt = GLFW.GetTime()

  while GLFW.WindowShouldClose(window) == 0
    t = GLFW.GetTime()
    dt = t - prevt # 1.0 / 60.0
    prevt = t
    total_time += dt

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

    NVG.BeginFrame(vg, winWidth, winHeight, pxRatio)
    NVG.Save(vg)

    $outer_graph.render(vg, color_scheme: :outer)
    $inner_graph.render(vg, color_scheme: :inner)

    $font_plane.render(vg, winWidth - 1200, 10, 1150, 700, "[MODE] #{$current_graph==$outer_graph ? 'Making Outer Polygon' : 'Making Inner Polygon'}", color: NVG.RGBA(32,128,64,255))
    $font_plane.render(vg, winWidth - 1200, 60, 1150, 700, "[TRIANGULATION] #{$outer_graph.triangle_indices.length > 0 ? 'Done' : 'Not Yet'}", color: NVG.RGBA(32,128,64,255))

    NVG.Restore(vg)
    NVG.EndFrame(vg)

    GLFW.SwapBuffers(window)
    GLFW.PollEvents()

=begin
    if total_time > 0.01
      $ss_name = sprintf("ss%05d.tga", $ss_id)
      save_screenshot(fbWidth, fbHeight, $ss_name)
      $ss_id += 1
    end
=end
  end

  NVG.DeleteGL2(vg)

  GLFW.Terminate()
end
