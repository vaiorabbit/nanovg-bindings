# Usage:
# $ ruby smallest_enclosing_circle.rb [-plot_spiral]
require 'opengl'
require 'glfw'
require 'rmath3d/rmath3d'
require_relative '../nanovg'

OpenGL.load_dll()
GLFW.load_dll()
NanoVG.load_dll('libnanovg_gl2.dylib')

include OpenGL
include GLFW
include NanoVG
include RMath3D

$plot_spiral = false

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

class Node
  attr_accessor :x, :y

  def initialize(x, y)
    @x = x
    @y = y
  end

  def to_vec
    RVec2.new(x, y)
  end
end

class Graph
  attr_accessor :nodes
  attr_reader :miniball_radius, :miniball_center_x, :miniball_center_y

  def initialize
    @nodes = []
    @undo_insert_index = -1
    @node_radius = 5.0

    @miniball_radius = -1.0
    @miniball_center_x = 0.0
    @miniball_center_y = 0.0
  end

  def add_node(x, y)
    @nodes << Node.new(x, y)
  end

  def insert_node(point_x, point_y)
    if @nodes.length < 3
      return add_node(point_x, point_y)
    end

    # Calculate distance from point to all edges.
    # Ref. : http://stackoverflow.com/questions/849211/shortest-distance-between-a-point-and-a-line-segment
    distances = Array.new(@nodes.length) { -Float::MAX }
    @nodes.each_with_index do |node_current, index|
#      print "edge[#{index}] : node[#{index}] - node[#{(index + 1) % @nodes.length}]\t"
      node_next = @nodes[(index + 1) % @nodes.length]
      edge_dir_x = node_next.x - node_current.x
      edge_dir_y = node_next.y - node_current.y
      edge_squared_length = edge_dir_x ** 2 + edge_dir_y ** 2
      if edge_squared_length < Float::EPSILON
        distances[index] = Math.sqrt((node_current.x - point_x)**2 + (node_current.y - point_y)**2)
        next
      end
      edge_start_to_point_x = point_x - node_current.x
      edge_start_to_point_y = point_y - node_current.y
      t = (edge_start_to_point_x * edge_dir_x + edge_start_to_point_y * edge_dir_y) / edge_squared_length
      if t < 0
        distances[index] = Math.sqrt((node_current.x - point_x)**2 + (node_current.y - point_y)**2)
      elsif t > 1
        distances[index] = Math.sqrt((node_next.x - point_x)**2 + (node_next.y - point_y)**2)
      else
        projection_x = node_current.x + t * edge_dir_x
        projection_y = node_current.y + t * edge_dir_y
        distances[index] = Math.sqrt((projection_x - point_x)**2 + (projection_y - point_y)**2)
      end
#      puts "distance=#{distances[index]}"
    end

    # Find nearest edge and insert new Node as a dividing point.
    minimum_distances = distances.min_by(2) {|d| d}
    nearest_edge_index = if minimum_distances[0] != minimum_distances[1]
                           distances.find_index( minimum_distances[0] )
                         else
                           # If the input point is in vertex Voronoi region, choose appropriate edge.
                           edge_node_indices = []
                           distances.each_with_index do |d, i|
                             edge_node_indices << [i, (i + 1) % nodes.length] if d == minimum_distances[0]
                             break if edge_node_indices.length == 2
                           end
                           nearest_node_index = (edge_node_indices[0] & edge_node_indices[1])[0]

                           other_node_index = nearest_node_index == edge_node_indices[0][0] ? edge_node_indices[0][1] : edge_node_indices[0][0]
                           edge0_x = @nodes[nearest_node_index].x - @nodes[other_node_index].x
                           edge0_y = @nodes[nearest_node_index].y - @nodes[other_node_index].y
                           edge0_length = Math.sqrt(edge0_x**2 + edge0_y**2)

                           edge0_x /= edge0_length
                           edge0_y /= edge0_length

                           edge0_to_point_x = point_x - @nodes[other_node_index].x
                           edge0_to_point_y = point_y - @nodes[other_node_index].y
                           edge0_to_point_length = Math.sqrt(edge0_to_point_x**2 + edge0_to_point_y**2)

                           edge0_to_point_x /= edge0_to_point_length
                           edge0_to_point_y /= edge0_to_point_length


                           other_node_index = nearest_node_index == edge_node_indices[1][0] ? edge_node_indices[1][1] : edge_node_indices[1][0]
                           edge1_x = @nodes[nearest_node_index].x - @nodes[other_node_index].x
                           edge1_y = @nodes[nearest_node_index].y - @nodes[other_node_index].y
                           edge1_length = Math.sqrt(edge1_x**2 + edge1_y**2)

                           edge1_x /= edge1_length
                           edge1_y /= edge1_length

                           edge1_to_point_x = point_x - @nodes[other_node_index].x
                           edge1_to_point_y = point_y - @nodes[other_node_index].y
                           edge1_to_point_length = Math.sqrt(edge1_to_point_x**2 + edge1_to_point_y**2)

                           edge1_to_point_x /= edge1_to_point_length
                           edge1_to_point_y /= edge1_to_point_length

                           dot_0 = edge0_x * edge0_to_point_x + edge0_y * edge0_to_point_y
                           dot_1 = edge1_x * edge1_to_point_x + edge1_y * edge1_to_point_y

#                           puts "#{dot_0}, #{dot_1}"
                           if dot_0 < dot_1
#                             p edge_node_indices[0]
                             edge_node_indices[0][0]
                           else
#                             p edge_node_indices[1]
                             edge_node_indices[1][0]
                           end
                         end

    @nodes.insert( nearest_edge_index + 1, Node.new(point_x, point_y) )
    @undo_insert_index = nearest_edge_index + 1
  end

  def undo_insert
    if @undo_insert_index >= 0
      @nodes.delete_at(@undo_insert_index)
      @undo_insert_index = -1
    end
  end

  def remove_nearest_node(point_x, point_y)
    distances = Array.new(@nodes.length) { -Float::MAX }
    @nodes.each_with_index do |node_current, index|
      distances[index] = (node_current.x - point_x)**2 + (node_current.y - point_y)**2
    end
    minimum_distance = distances.min_by {|d| d}
    if minimum_distance <= @node_radius ** 2
      nearest_node_index = distances.find_index( minimum_distance )
      @nodes.delete_at(nearest_node_index)
      @undo_insert_index = -1
    end
  end

  def clear
    @nodes.clear
  end

  def sec_recurse(head, p, b)
    r = Float::EPSILON
    c = RVec2.new(0, 0)

    case b
    when 0;
      r = -1.0
    when 1
      r = Float::EPSILON
      c = @P[head-1].to_vec
    when 2
      o = @P[head-1].to_vec
      a = @P[head-2].to_vec
      vec_oa = a - o
      vec_o = 0.5 * vec_oa
      r = vec_o.getLength
      c = o + vec_o
    when 3
      # https://en.wikipedia.org/wiki/Circumscribed_circle
      o = @P[head-1].to_vec
      a = @P[head-2].to_vec
      b = @P[head-3].to_vec
      vec_oa = a - o
      vec_ob = b - o
      r = vec_oa.getLength * vec_ob.getLength * (vec_oa - vec_ob).getLength / (2.0 * RVec2.cross(vec_oa, vec_ob)).abs
      denominator = 2.0 * (RVec2.cross(vec_oa, vec_ob) ** 2)
      axb = RVec2.cross(vec_oa, vec_ob)
      vec_o = (vec_oa.getLengthSq * vec_ob - vec_ob.getLengthSq * vec_oa) 
      vec_o.x, vec_o.y = axb * vec_o.y, -axb * vec_o.x # virtual cross product with (0, 0, |a x b|)

      vec_o = vec_o * (1.0 / denominator)
      c = o + vec_o
      return r, c
    end

    for i in 0 ... p
      p_i = @P[head+i].to_vec
      if (p_i - c).getLengthSq - r*r > 0
        i.step(to: 1, by: -1) do |j|
          @P[head+j], @P[head+j-1] = @P[head+j-1], @P[head+j]
        end
        r, c = sec_recurse(head+1, i, b+1)
      end
    end

    return r, c
  end
  private :sec_recurse

  # Ref.: http://www.flipcode.com/archives/Smallest_Enclosing_Spheres.shtml
  def smallest_enclosing_circle
    @P = @nodes.dup.shuffle! # randomization for faster computation
    r, c = sec_recurse(0 ,@P.length, 0)
    @miniball_radius = r
    @miniball_center_x = c.x
    @miniball_center_y = c.y
    return r, c
  end

  def render(vg, render_edge: false, render_node: true)
    # Edges
    if render_edge and @nodes.length >= 2
      color = nvgRGBA(192,128,192, 255)
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

    # Smallest Enclosing Circle
    if @miniball_radius > 0
      color = nvgRGBA(255,0,0, 64)
      nvgBeginPath(vg)
      nvgCircle(vg, @miniball_center_x, @miniball_center_y, @miniball_radius)
      nvgFillColor(vg, color)
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
  elsif key == GLFW_KEY_Z && action == GLFW_PRESS && (mods & GLFW_MOD_CONTROL != 0) # Remove the last node your added by Ctrl-Z.
    $graph.undo_insert
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
    $graph.insert_node(sx, sy)
    $graph.smallest_enclosing_circle
    $spiral_theta += 10.0 * Math::PI/180
    $spiral_radius += 2.0
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
    else
      $graph.insert_node(mx, my)
      $graph.smallest_enclosing_circle
    end
  end
end


if __FILE__ == $0

  $plot_spiral = ARGV[0] == "-plot_spiral"

  if glfwInit() == GL_FALSE
    puts("Failed to init GLFW.")
    exit
  end

  glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 2)
  glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 0)

  window = glfwCreateWindow( 1280, 720, "Smallest Enclosing Circle", nil, nil )
  if window == 0
    glfwTerminate()
    exit
  end

  glfwSetKeyCallback( window, key )
  glfwSetMouseButtonCallback( window, mouse )

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

    if $plot_spiral && total_time > 0.1
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
