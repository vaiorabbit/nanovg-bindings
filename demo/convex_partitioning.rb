require 'rmath3d/rmath3d_plain'
include RMath3D

class RVec2
  def ==( other )
    if other.class == RVec2
      return (x-other.x).abs<=Float::EPSILON && (y-other.y).abs<=Float::EPSILON
    else
      return false
    end
  end
end

require_relative 'triangle'

module ConvexPartitioning

  # Ear-cutting algorithm
  # Ref.: Christer Ericson, Real-Time Collision Detection
  def self.triangulate(polygon_points)
    triangles = []
    indices = []
    n = polygon_points.length
    v = polygon_points

    indices_prev = []
    indices_next = []
    n.times do |i|
      indices_prev << i - 1
      indices_next << i + 1
    end
    indices_prev[0] = n - 1
    indices_next[n - 1] = 0

    i = 0
    while n > 3
      is_ear = true
      if Triangle.ccw(v[indices_prev[i]], v[i], v[indices_next[i]]) < 0
        k = indices_next[indices_next[i]]
        begin
          if Triangle.contains(v[k],  v[indices_prev[i]], v[i], v[indices_next[i]])
            is_ear = false
            break
          end
          k = indices_next[k]
        end while k != indices_prev[i]
      else
        is_ear = false
      end

      if is_ear
        indices << [indices_prev[i], i, indices_next[i]]
        indices_next[indices_prev[i]] = indices_next[i]
        indices_prev[indices_next[i]] = indices_prev[i]
        n -= 1
        i = indices_prev[i]
      else
        i = indices_next[i]
      end
    end # while n > 3

    indices << [indices_prev[i], i, indices_next[i]]

    return indices
  end

  # Ref.: https://rootllama.wordpress.com/2014/06/20/ray-line-segment-intersection-test-in-2d/
  def self.segment_ray_intersect?(a, b, o, d)
    v1 = o - a
    v2 = b - a
    v3 = RVec2.new(-d.y, d.x)
    t1 = RVec2.cross(v2, v1) / RVec2.dot(v2, v3)
    t2 = RVec2.dot(v1, v3) / RVec2.dot(v2, v3)
    #p a, b, o, d
    #p v1, v2, v3
    #p t1, t2
    #p RVec2.cross(v2, v1)
    intersect = (t1 >= 0 && (0 <= t2 && t2 <= 1)) ? true : false
    return nil unless intersect
    return o + t1 * d
  end

  # Ref.: David Eberly, "Triangulation by Ear Clipping"
  # http://www.geometrictools.com/Documentation/TriangulationByEarClipping.pdf
  def self.find_mutually_visible_vertices(outer_polygon, inner_polygon)
    # Search the inner polygon for vertex M of maximum x-value.
    vertex_M = inner_polygon.max_by {|v| v.x}

    # Let I be the closest visible point to M on the ray M + t(1, 0).
    vertex_I = RVec2.new(Float::MAX, vertex_M.y)
    vertex_P = nil
    outer_polygon.each_with_index do |vertex_current, index|
      # next if vertex_current.x < vertex_M.x
      vertex_next = outer_polygon[(index + 1) % outer_polygon.length]
      # next if vertex_next.x < vertex_M.x
      edge_dir = vertex_next - vertex_current
      vertex_I_new = segment_ray_intersect?(vertex_current, vertex_next, vertex_M, RVec2.new(1.0, 0.0))
      if vertex_I_new != nil && vertex_I_new.x < vertex_I.x
        vertex_I = vertex_I_new
        # I is an interior point of the edge. Select P to be the endpoint of maximum x-value for this edge.
        vertex_P = vertex_current.x >= vertex_next.x ? vertex_current : vertex_next
      end
    end

    # Search the reflex vertices of th eouter polygon.
    vertex_R = nil
    angle_MR = Math::PI
    outer_polygon.each_with_index do |vertex_current, index|
      vertex_prev = outer_polygon[(index - 1 + outer_polygon.length) % outer_polygon.length]
      vertex_next = outer_polygon[(index + 1) % outer_polygon.length]
      vertex_is_reflex = Triangle.ccw(vertex_prev, vertex_current, vertex_next) > 0
      if vertex_is_reflex
        is_inside = Triangle.contains(vertex_current, vertex_M, vertex_I, vertex_P)
        if is_inside
          # At least one reflex vertex lies in <M, I, P>. Search for the reflex R that minimizes
          # the angle between (1, 0) and the line segment <M, R>. The M and R are mutually visible.
          angle_MR_new = Math.acos(RVec2.dot((vertex_current - vertex_M).getNormalized, RVec2.new(1,0)).abs)
          if angle_MR_new < angle_MR
            angle_MR = angle_MR_new
            vertex_R = vertex_current
          end
        end
      end
    end
    # If all of these vertices are strictly outside triangle <M, I, P> then M and P are mutually visible.
    vertex_R = vertex_P if vertex_R == nil
    index_outer = outer_polygon.find_index(vertex_R)
    index_inner = inner_polygon.find_index(vertex_M)
    return index_outer, index_inner
  end

end

if __FILE__ == $0
  points = []

#  points << RVec2.new(0.0, 0.0)
  points << RVec2.new(1.0, 0.0)
  points << RVec2.new(0.0, -1.0)
  points << RVec2.new(-1.0, 0.0)
  points << RVec2.new(0.0, 1.0)

  p indices = ConvexPartitioning.triangulate(points)
end
