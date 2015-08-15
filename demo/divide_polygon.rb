# Usage:
# $ gem install rmath3d_plain
# $ ruby divide_polygon.rb
require 'pp'
require 'opengl'
require 'glfw'
require 'rmath3d/rmath3d_plain'
require_relative '../nanovg'
require_relative './convex_partitioning'
require_relative './segment_intersection'


OpenGL.load_lib()
GLFW.load_lib()
NanoVG.load_dll('libnanovg_gl2.dylib')

include OpenGL
include GLFW
include NanoVG
include RMath3D

$plot_spiral = false
$plot_random = false

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
      return add_node(point_x, point_y)
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
    minimum_distances = distances.min_by(2) {|d| d}
    nearest_edge_index = if minimum_distances[0] != minimum_distances[1]
                           distances.find_index( minimum_distances[0] )
                         else
                           # If the input point is in vertex Voronoi region, choose appropriate edge.
                           segment_indices = []
                           edge_node_indices = []
                           distances.each_with_index do |d, i|
                             indices = [i, (i + 1) % @nodes.length]
                             segment_indices << indices
                             if edge_node_indices.length < 2 && d == minimum_distances[0]
                               edge_node_indices << indices
                             end
                           end
                           nearest_node_index = (edge_node_indices[0] & edge_node_indices[1])[0]

#pp segment_indices, edge_node_indices, segment_indices - [edge_node_indices[0]]
#pp @nodes, @nodes + [point]
#pp segment_indices + [[edge_node_indices[0][0], @nodes.length], [@nodes.length, edge_node_indices[0][1]]]
#                           pp SegmentIntersection.check(@nodes, segment_indices)
                           e0_self_intersect = SegmentIntersection.check(@nodes + [point], segment_indices - [edge_node_indices[0]] + [[edge_node_indices[0][0], @nodes.length], [@nodes.length, edge_node_indices[0][1]]])
                           e1_self_intersect = SegmentIntersection.check(@nodes + [point], segment_indices - [edge_node_indices[1]] + [[edge_node_indices[1][0], @nodes.length], [@nodes.length, edge_node_indices[1][1]]])
print "e0_int=#{e0_self_intersect}, e1_int=#{e1_self_intersect} => "

                           if e0_self_intersect
                             puts "Take e1"
                             edge_node_indices[0][1]
                           else
                             puts "Take e0"
                             edge_node_indices[0][0]
                           end

                           ####################
=begin
                           other_node_index = nearest_node_index == edge_node_indices[0][0] ? edge_node_indices[0][1] : edge_node_indices[0][0]
                           edge0 = @nodes[nearest_node_index] - @nodes[other_node_index]
                           edge0.normalize!

                           edge0_to_point = point - @nodes[other_node_index]
                           edge0_to_point.normalize!


                           other_node_index = nearest_node_index == edge_node_indices[1][0] ? edge_node_indices[1][1] : edge_node_indices[1][0]
                           edge1 = @nodes[nearest_node_index] - @nodes[other_node_index]
                           edge1.normalize!

                           edge1_to_point = point - @nodes[other_node_index]
                           edge1_to_point.normalize!

                           dot_0 = RVec2.dot(edge0, edge0_to_point)
                           dot_1 = RVec2.dot(edge1, edge1_to_point)

                           if dot_0 < dot_1
                             puts "Take e0"
                             edge_node_indices[0][0]
                           else
                             puts "Take e1"
                             edge_node_indices[1][0]
                           end
=end
                         end

    @nodes.insert( nearest_edge_index + 1, RVec2.new(point_x, point_y) )
    @undo_insert_index = nearest_edge_index + 1
  end

  def undo_insert
    if @undo_insert_index >= 0
      @nodes.delete_at(@undo_insert_index)
      @undo_insert_index = -1
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

  def render(vg, render_edge: true, render_node: true)
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
      color = nvgRGBA(0,0,255, 255)
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
      color = nvgRGBA(0,192,255, 255)
      nvgBeginPath(vg)
      @nodes.each do |node|
        nvgCircle(vg, node.x, node.y, @node_radius)
        nvgFillColor(vg, color)
      end
      nvgFill(vg)
    end

  end
end

$graph = Graph.new


key = GLFW::create_callback(:GLFWkeyfun) do |window, key, scancode, action, mods|
  if key == GLFW_KEY_ESCAPE && action == GLFW_PRESS # Press ESC to exit.
    glfwSetWindowShouldClose(window, GL_TRUE)
  elsif key == GLFW_KEY_R && action == GLFW_PRESS # Press 'R' to clear graph.
    $graph.clear
  end
end

$spiral_theta = 0.0
$spiral_radius = Float::EPSILON

mouse = GLFW::create_callback(:GLFWmousebuttonfun) do |window_handle, button, action, mods|
  if $plot_spiral
    sx = $spiral_radius * Math.cos($spiral_theta)
    sy = $spiral_radius * Math.sin($spiral_theta)
    sx += 1280 * 0.5
    sy += 720 * 0.5
    $graph.insert_node(sx, sy) # $graph.add_node(sx, sy)
    $graph.triangulate
    $spiral_theta += 22.0 * Math::PI/180 # Math::PI * (3 - Math.sqrt(5)) # golden angle in radian
    $spiral_radius += 4.0
    return
  end

  if $plot_random
    sx = rand(1280.0)
    sy = rand(720.0)
    $graph.insert_node(sx, sy) # add_node(sx, sy)
    $graph.triangulate
    return
  end

  if button == GLFW_MOUSE_BUTTON_LEFT && action == 0
    mx_buf = ' ' * 8
    my_buf = ' ' * 8
    glfwGetCursorPos(window_handle, mx_buf, my_buf)
    mx = mx_buf.unpack('D')[0]
    my = my_buf.unpack('D')[0]
    if (mods & GLFW_MOD_SHIFT) != 0
      $graph.remove_nearest_node(mx, my)
      if $graph.nodes.length <= 2
        $graph.clear
      else
        $graph.triangulate
      end
    else
      $graph.insert_node(mx, my) # add_node(mx, my)
      $graph.triangulate
    end
  end
end


if __FILE__ == $0

  $plot_spiral = ARGV[0] == "-plot_spiral"
  $plot_random = ARGV[0] == "-plot_random"

  if glfwInit() == GL_FALSE
    puts("Failed to init GLFW.")
    exit
  end

  glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 2)
  glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 0)

  window = glfwCreateWindow( 1280, 720, "Triangulation", nil, nil )
  if window == 0
    glfwTerminate()
    exit
  end

  glfwSetKeyCallback( window, key )
  if $plot_spiral == false && $plot_random == false
    glfwSetMouseButtonCallback( window, mouse )
  end

  glfwMakeContextCurrent( window )

  nvgSetupGL2()
  vg = nvgCreateGL2(NVG_ANTIALIAS | NVG_STENCIL_STROKES)
  if vg == nil
    puts("Could not init nanovg.")
    exit
  end

  winWidth_buf  = '        '
  winHeight_buf = '        '
  fbWidth_buf  = '        '
  fbHeight_buf = '        '

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

    $graph.render(vg)

    nvgRestore(vg)
    nvgEndFrame(vg)

    glfwSwapBuffers( window )
    glfwPollEvents()

    if ($plot_spiral || $plot_random) && total_time > 0.01
      mouse.call(window, 0, 0, 0)
      total_time = 0
=begin
      $ss_name = sprintf("ss%05d.tga", $ss_id)
      save_screenshot(fbWidth, fbHeight, $ss_name)
      $ss_id += 1
=end
    end
  end

  nvgDeleteGL2(vg)

  glfwTerminate()
end
