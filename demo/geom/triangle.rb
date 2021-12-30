# coding: utf-8

require 'rmath3d/rmath3d_plain'
include RMath3D

require_relative 'minicircle'

class Triangle

  attr_accessor :vertex, :edge
  attr_reader :cr, :cc

  def initialize(vtx)
    @vertex = vtx
    @edge = [[@vertex[0], @vertex[1]],
             [@vertex[1], @vertex[2]],
             [@vertex[2], @vertex[0]]]
    r, c = SmallestEnclosingCircle.circumcircle(@vertex[0], @vertex[1], @vertex[2])
    @cr = r
    @cc = c
  end

  def same_edge(idx, other_edge)
    if ( ((@edge[idx][0] - other_edge[0]).getLengthSq <= Float::EPSILON &&
          (@edge[idx][1] - other_edge[1]).getLengthSq <= Float::EPSILON ) ||
         ((@edge[idx][1] - other_edge[0]).getLengthSq <= Float::EPSILON &&
          (@edge[idx][0] - other_edge[1]).getLengthSq <= Float::EPSILON ) )
      return true
    end
    return false
  end

  def has_edge(other_edge)
    3.times do |idx|
      return true if same_edge(idx, other_edge)
    end
    return false
  end

  def has_vertex(pnt)
    @vertex.each do |vtx|
      return true if (vtx - pnt).getLengthSq <= Float::EPSILON
    end
    return false
  end

  def ==(other_tri)
    return false if other_tri == nil
    @vertex.each do |vtx|
      return false unless other_tri.has_vertex(vtx)
    end
    return true
  end

  def non_edge_vertex(edge)
    @vertex.each do |vtx|
      return vtx if vtx != edge[0] && vtx != edge[1]
    end
    return nil
  end

  def circumcircle_contains(point)
    return (point - @cc).getLengthSq < @cr**2
  end

  ################################################################################

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

  # Christer Ericson, Real-Time Collision Detection, Ch 5.1.5
  def self.closest_point(p, a, b, c)
    ab = b - a
    ac = c - a
    ap = p - a
    d1 = RVec2.dot(ab, ap)
    d2 = RVec2.dot(ac, ap)
    return a, [1.0, 0.0, 0.0] if d1 <= 0.0 && d2 <= 0.0

    bp = p - b
    d3 = RVec2.dot(ab, bp)
    d4 = RVec2.dot(ac, bp)
    return b, [0.0, 1.0, 0.0] if d3 >= 0.0 && d4 <= d3

    vc = d1*d4 - d3*d2
    if vc <= 0.0 && d1 >= 0.0 && d3 <= 0.0
      v = d1 / (d1 - d3)
      return a + v * ab, [v, 1-v, 0.0]
    end

    cp = p - c
    d5 = RVec2.dot(ab, cp)
    d6 = RVec2.dot(ac, cp)
    return c, [0.0, 0.0, 1.0] if d6 >= 0.0 && d5 <= d6

    vb = d5*d2 - d1*d6
    if vb <= 0.0 && d2 >= 0.0 && d6 <= 0.0
      w = d2 / (d2 - d6)
      return a + w * ac, [1-w, 0.0, w]
    end

    va = d3*d6 - d5*d4
    if va <= 0.0 && (d4 - d3) >= 0.0 && (d5 - d6) >= 0.0
      w = (d4 - d3) / ((d4 - d3) + (d5 - d6))
      return b + w * (c - b), [0.0, 1-w, w]
    end

    denom = 1.0 / (va + vb + vc)
    v = vb * denom
    w = vc * denom
    return a + ab * v + ac * w, [1-v-w, v, w]
  end

  # returns 2x signed area of a triangle abc
  def self.signed_area(a, b, c)
    return (a.x - c.x) * (b.y - c.y) - (a.y - c.y) * (b.x - c.x)
  end

  def self.contains(p, a, b, c)
    closest_point, barycentric_coodinates = self.closest_point(p, a, b, c)

    return (0.0 < barycentric_coodinates[0] && barycentric_coodinates[0] < 1.0) && (0.0 < barycentric_coodinates[1] && barycentric_coodinates[1] < 1.0) && (barycentric_coodinates[0] + barycentric_coodinates[1] < 1.0) ? true : false
    # return (0.0 <= barycentric_coodinates[0] && barycentric_coodinates[0] <= 1.0) && (0.0 <= barycentric_coodinates[1] && barycentric_coodinates[1] <= 1.0) && (barycentric_coodinates[0] + barycentric_coodinates[1] <= 1.0) ? true : false
  end

end
