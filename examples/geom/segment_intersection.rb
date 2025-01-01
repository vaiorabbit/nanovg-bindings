# Ref.: http://geomalgorithms.com/a09-_intersect-3.html
#       http://stackoverflow.com/questions/4876065/check-if-polygon-is-self-intersecting
require 'rmath3d/rmath3d_plain'
include RMath3D

require_relative 'triangle'

module SegmentIntersection

  # Ref.: Real-Time Collision Detection, Ch. 5.1.9.1
  def self.intersect?(a, b, c, d)
    a1 = Triangle.signed_area(a, b, d)
    a2 = Triangle.signed_area(a, b, c)
    if a1 * a2 < 0
      a3 = Triangle.signed_area(c, d, a)
      a4 = a3 + a2 - a1 # == Triangle.signed_area(c, d, b)
      # t = a3 / (a3 - a4)
      # p = a + t * (b - a)
      return a3 / (a3 - a4) if a3 * a4 < 0
    end
    return nil
  end

  def self.find(points, indices)
    return find_Bruteforce(points, indices)
  end

  def self.find_Bruteforce(points, indices)
    # TODO
  end

  def self.find_BentleyOttmann(points, indices)
    # TODO
  end

  def self.check(points, indices)
    return check_Bruteforce(points, indices)
  end

  def self.check_Bruteforce(points, indices)
    for i in 0...(indices.length - 1) do
      for j in i...indices.length do
        return true if intersect?(points[indices[i][0]], points[indices[i][1]], points[indices[j][0]], points[indices[j][1]])
      end
    end
    return false
  end

  def self.check_ShamosHoey(points, indices)
    # TODO
  end

end

if __FILE__ == $0
  points = []

  points << RVec2.new(1.0, 0.0)
  points << RVec2.new(0.0, -1.0)
  points << RVec2.new(-1.0, 0.0)
  points << RVec2.new(0.0, 1.0)
  points << RVec2.new(0.0, 0.0)
  points << RVec2.new(1.0, 1.0)

  indices = [[0, 1], [1, 2], [2, 3], [3, 0], [4, 5]]

  p SegmentIntersection.check(points, indices)
end
