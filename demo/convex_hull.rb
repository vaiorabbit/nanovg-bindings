# coding: utf-8
require 'rmath3d/rmath3d_plain'
include RMath3D

module ConvexHull

  def self.calculate(points_original)
    return nil if points_original.length <= 2

    # return self.calculate_PackageWrapping(points_original.dup)
    return self.calculate_AndrewsConvexHullScan(points_original.dup)
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

  # Ref.: Sedgewick, Algorithms in C++
  def self.calculate_PackageWrapping(points)
    n = points.length
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
      if min_index == n
        return indices[0..m]
      end
    end
  end

  # Ref.: Heineman et al., Algorithms in a Nutshell
  def self.calculate_AndrewsConvexHullScan(points)
    n = points.length

    indices = (0...points.length).to_a
    indices.sort! do |i, j| # x -> y sorter
      r = 0
      dx = points[i].x - points[j].x
      r = -1 if dx < 0
      r = +1 if dx > 0
      if r == 0
        dy = points[i].y - points[j].y
        r = -1 if dy < 0
        r = +1 if dy > 0
      end
      r
    end

    # partial hull (upper)
    upper = [indices[0], indices[1]]
    for i in 2...n do
      upper << indices[i]
      # remove middle of the last three points if they form a concave curve.
      while upper.length >= 3 && ccw(points[upper[upper.length-3]], points[upper[upper.length-2]], points[upper[upper.length-1]]) > 0
        upper.delete_at(upper.length-2)
      end
    end

    # patial hull (lower)
    lower = [indices[n-1], indices[n-2]]
    (n-3).downto(0) do |i|
      lower << indices[i]
      # remove middle of the last three points if they form a concave curve.
      while lower.length >= 3 && ccw(points[lower[lower.length-3]], points[lower[lower.length-2]], points[lower[lower.length-1]]) > 0
        lower.delete_at(lower.length-2)
      end
    end

    # merge two partial hulls.
    return (upper + lower).uniq!
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
