# coding: utf-8
# Usage:
# $ gem install rmath3d_plain
# $ ruby hole_polygon.rb
require 'opengl'
require 'glfw'
require 'rmath3d/rmath3d_plain'
require_relative '../nanovg'
require_relative './convex_partitioning'
require_relative './segment_intersection'


OpenGL.load_lib()
GLFW.load_lib()
NanoVG.load_dll('libnanovg_gl3.dylib', render_backend: :gl3)

include OpenGL
include GLFW
include NanoVG
include RMath3D

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

class FontPlane
  def initialize
    @fonts = []
  end

  def load(vg, name="sans", ttf="./jpfont/GenShinGothic-Bold.ttf")
    font_handle = nvgCreateFont(vg, name, ttf)
    if font_handle == -1
      puts "Could not add font."
      return -1
    end
    @fonts << font_handle
  end

  def render(vg, x, y, width, height, text, name: "sans", color: nvgRGBA(255,255,255,255))
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
#        nvgFillColor(vg, nvgRGBA(255,255,255, 0))
#        nvgRect(vg, x, y, row[:width], lineh)
#        nvgFill(vg)

        nvgFillColor(vg, color)
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
      i = distances.find_index( minimum_distances[0] )
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

    @nodes.insert( nearest_edge_index + 1, RVec2.new(point_x, point_y) )
    @undo_insert_index = nearest_edge_index + 1
  end

  def undo_insert
    if @undo_insert_index >= 0
      @nodes.delete_at(@undo_insert_index)
      @undo_insert_index = -1
      if $outer_graph.nodes.length <= 2
        $outer_graph.clear
#      else
#        $outer_graph.triangulate
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
      nearest_node_index = distances.find_index( minimum_distance )
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
      color = nvgRGBA(0,255,0, 255)
      lw = @node_radius * 0.5
      @triangle_indices.each do |indices|
        nvgLineCap(vg, NVG_ROUND)
        nvgLineJoin(vg, NVG_ROUND)
        nvgBeginPath(vg)
        nvgMoveTo(vg, @nodes[indices[0]].x, @nodes[indices[0]].y)
        nvgLineTo(vg, @nodes[indices[1]].x, @nodes[indices[1]].y)
        nvgLineTo(vg, @nodes[indices[2]].x, @nodes[indices[2]].y)
        nvgClosePath(vg)
        color = nvgRGBA(0,255,0, 64)
        nvgFillColor(vg, color)
        nvgFill(vg)
        color = nvgRGBA(255,128,0, 255)
        nvgStrokeColor(vg, color)
        nvgStrokeWidth(vg, lw)
        nvgStroke(vg)
      end
    end

    # Edges
    if render_edge and @nodes.length >= 2
      color = color_scheme == :outer ? nvgRGBA(0,0,255, 255) : nvgRGBA(255,0,0, 255)
      lw = @node_radius * 0.5
      nvgLineCap(vg, NVG_ROUND)
      nvgLineJoin(vg, NVG_ROUND)
      nvgBeginPath(vg)
      @nodes.length.times do |i|
        if i == 0
          nvgMoveTo(vg, @nodes[0].x, @nodes[0].y)
        else
          nvgLineTo(vg, @nodes[i].x, @nodes[i].y)
        end
      end
      nvgClosePath(vg)
      nvgStrokeColor(vg, color)
      nvgStrokeWidth(vg, lw)
      nvgStroke(vg)
    end

    # Nodes
    if render_node and @nodes.length > 0
      color = color_scheme == :outer ? nvgRGBA(0,192,255, 255) : nvgRGBA(255,192,0, 255)
      nvgBeginPath(vg)
      @nodes.each do |node|
        nvgCircle(vg, node.x, node.y, @node_radius)
        nvgFillColor(vg, color)
      end
      nvgFill(vg)
    end

  end
end

$font_plane = FontPlane.new

$outer_graph = Graph.new
$inner_graph = Graph.new
$current_graph = $outer_graph

$mutual_visible_path = []

key = GLFW::create_callback(:GLFWkeyfun) do |window, key, scancode, action, mods|
  if key == GLFW_KEY_ESCAPE && action == GLFW_PRESS # Press ESC to exit.
    glfwSetWindowShouldClose(window, GL_TRUE)
  elsif key == GLFW_KEY_SPACE && action == GLFW_PRESS
    $current_graph = $current_graph == $inner_graph ? $outer_graph : $inner_graph
  elsif key == GLFW_KEY_R && action == GLFW_PRESS # Press 'R' to clear graph.
    $current_graph.clear
    $mutual_visible_path.clear
  elsif key == GLFW_KEY_M && action == GLFW_PRESS # Press 'M' to merge inner polygon.
    index_outer, index_inner = ConvexPartitioning.find_mutually_visible_vertices($outer_graph.nodes, $inner_graph.nodes)
    $mutual_visible_path = [index_outer, index_inner]
  elsif key == GLFW_KEY_Z && action == GLFW_PRESS && (mods & GLFW_MOD_CONTROL != 0) # Remove the last node your added by Ctrl-Z.
    $current_graph.undo_insert
    $mutual_visible_path.clear
  end
end

mouse = GLFW::create_callback(:GLFWmousebuttonfun) do |window_handle, button, action, mods|
  if button == GLFW_MOUSE_BUTTON_LEFT && action == 0
    mx_buf = ' ' * 8
    my_buf = ' ' * 8
    glfwGetCursorPos(window_handle, mx_buf, my_buf)
    mx = mx_buf.unpack('D')[0]
    my = my_buf.unpack('D')[0]
    if (mods & GLFW_MOD_SHIFT) != 0
      $current_graph.remove_nearest_node(mx, my)
      if $current_graph.nodes.length <= 2
        $current_graph.clear
#      else
#        $current_graph.triangulate
      end
      $mutual_visible_path.clear
    else
      $current_graph.insert_node(mx, my) # add_node(mx, my)
#      $current_graph.triangulate
      $mutual_visible_path.clear
    end
  end
end


if __FILE__ == $0

  if glfwInit() == GL_FALSE
    puts("Failed to init GLFW.")
    exit
  end

  # glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 2)
  # glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 0)
    glfwDefaultWindowHints()
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE)
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE)
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4)
    glfwWindowHint(GLFW_DECORATED, 0)

  window = glfwCreateWindow( 1280, 720, "Triangulation", nil, nil )
  if window == 0
    glfwTerminate()
    exit
  end

  glfwSetKeyCallback( window, key )
  glfwSetMouseButtonCallback( window, mouse )

  glfwMakeContextCurrent( window )

  nvgSetupGL3()
  vg = nvgCreateGL3(NVG_ANTIALIAS | NVG_STENCIL_STROKES)
  if vg == nil
    puts("Could not init nanovg.")
    exit
  end

  winWidth_buf  = '        '
  winHeight_buf = '        '
  fbWidth_buf  = '        '
  fbHeight_buf = '        '

  $font_plane.load(vg, "sans", "./jpfont/GenShinGothic-Normal.ttf")

  glfwSwapInterval(0)
  glfwSetTime(0)

  total_time = 0.0

  prevt = glfwGetTime()

  while glfwWindowShouldClose( window ) == 0
    t = glfwGetTime()
    dt = t - prevt # 1.0 / 60.0
    prevt = t
    total_time += dt

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

    nvgBeginFrame(vg, winWidth, winHeight, pxRatio)
    nvgSave(vg)

    $outer_graph.render(vg, color_scheme: :outer)
    $inner_graph.render(vg, color_scheme: :inner)

    if $mutual_visible_path.length > 0
      color = nvgRGBA(0,255,0, 255)
      lw = 5.0
      nvgLineCap(vg, NVG_ROUND)
      nvgLineJoin(vg, NVG_ROUND)
      nvgBeginPath(vg)
      nvgMoveTo(vg, $outer_graph.nodes[$mutual_visible_path[0]].x, $outer_graph.nodes[$mutual_visible_path[0]].y)
      nvgLineTo(vg, $inner_graph.nodes[$mutual_visible_path[1]].x, $inner_graph.nodes[$mutual_visible_path[1]].y)
      nvgClosePath(vg)
      nvgStrokeColor(vg, color)
      nvgStrokeWidth(vg, lw)
      nvgStroke(vg)
    end

    $font_plane.render(vg, winWidth - 1200, 10, 1150, 700, "[MODE] #{$current_graph==$outer_graph ? 'Making Outer Polygon' : 'Making Inner Polygon'}", color: nvgRGBA(32,128,64,255))
    $font_plane.render(vg, winWidth - 1200, 60, 1150, 700, "[TRIANGULATION] #{$outer_graph.triangle_indices.length > 0 ? 'Done' : 'Not Yet'}", color: nvgRGBA(32,128,64,255))

    nvgRestore(vg)
    nvgEndFrame(vg)

    glfwSwapBuffers( window )
    glfwPollEvents()

=begin
    if total_time > 0.01
      $ss_name = sprintf("ss%05d.tga", $ss_id)
      save_screenshot(fbWidth, fbHeight, $ss_name)
      $ss_id += 1
    end
=end
  end

  nvgDeleteGL3(vg)

  glfwTerminate()
end
