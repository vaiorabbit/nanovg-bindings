require 'rmath3d/rmath3d_plain'
include RMath3D

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
