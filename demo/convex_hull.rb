# coding: utf-8
# Ref.: Sedgewick, Algorithms in C++
require 'rmath3d/rmath3d_plain'
include RMath3D

module ConvexHull

  def self.calculate(points_original)
    points = points_original.dup
    points_count = points.length
    hull_index, indices = self.calculate_PackageWrapping(points, points_count)
    return indices[0..hull_index]
  end

  # +1 : counterclockwise / collinear (p0 is in between p1 and p2).
  # -1 : clockwise / collinear (p2 is in between p0 and p1).
  #  0 : collinear (p1 is in between p0 and p2)
  def self.ccw(p0, p1, p2)
    dx1 = p1.x - p0.x
    dy1 = p1.y - p0.y
    dx2 = p2.x - p0.x
    dy2 = p2.y - p0.y
    return +1 if dx1*dy2 > dy1*dx2
    return -1 if dx1*dy2 < dy1*dx2
    return -1 if (dx1*dx2 < 0) || (dy1*dy2 < 0)
    return +1 if dx1**2 + dy1**2 < dx2**2 + dy2**2
    return 0
  end

  def self.theta(p1, p2)
    dx = p2.x - p1.x
    dy = p2.y - p1.y
    ax = dx.abs
    ay = dy.abs
    t = (ax + ay <= Float::EPSILON) ? 0 : dy / (ax + ay)
    if dx < 0
      t = 2 - t
    elsif dy < 0
      t = 4 + t
    end
    return t * 90.0
  end

  def self.calculate_PackageWrapping(points, n)
    p_min = points.min_by {|p| p.y}
    min_index = points.find_index(p_min)
    points[n] = points[min_index] # sentinel
    indices = (0...points.length).to_a
    indices[n] = indices[min_index]

    v = 0.0
    th = 0.0
    n.times do |m|
      points[m], points[min_index] = points[min_index], points[m] # swap
      indices[m], indices[min_index] = indices[min_index], indices[m] # swap
      min_index = n
      v = th
      th = 360.0
      for i in (m+1)..n do
        t = theta(points[m], points[i])
        if t > v && t < th
          min_index = i
          th = t
        end
      end
      return m, indices if min_index == n
    end
  end

  def self.calculate_GrahamScan(points)
    indices = []
    return indices
  end

end

if __FILE__ == $0
  points = []

  points << RVec2.new(0.0, 0.0)
  points << RVec2.new(1.0, 0.0)
  points << RVec2.new(-1.0, 0.0)
  points << RVec2.new(0.0, 1.0)
  points << RVec2.new(0.0, -1.0)

  indices = ConvexHull.calculate(points)
  indices.each_with_index do |indices, i|
    puts "Convex Hull(#{i}) : #{points[indices]}"
  end
end
