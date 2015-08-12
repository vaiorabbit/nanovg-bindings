# coding: utf-8
# Ref.: https://en.wikipedia.org/wiki/Bowyer–Watson_algorithm
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

end


module DelaunayTriangulation

  def self.calculate(points_original)
    points = points_original.dup
    triangles = []
    incircle_r, incircle_c = SmallestEnclosingCircle.calculate(points)
    st_scale = 10000.0 # smaller supertriangle tend to produce false-positive bad triangles
    st_hle = Math.sqrt(3) * incircle_r * st_scale # half length of super triangle's edge
    super_tri = Triangle.new([RVec2.new(-st_hle, -incircle_r) + incircle_c,
                              RVec2.new(st_hle, -incircle_r) + incircle_c,
                              RVec2.new(0.0, Math.sqrt(incircle_r**2 + st_hle**2)) + incircle_c
                             ])

    triangles << super_tri

    points.each do |pnt|
      bad_triangles = []
      triangles.each do |tri|
        bad_triangles << tri if tri.circumcircle_contains(pnt)
      end

      polygon = []
      bad_triangles.each do |tri|
        tri.edge.each do |e|
          shared = false
          bad_triangles.each do |other_tri|
            next if other_tri == tri
            if other_tri.has_edge(e)
              shared = true
              break
            end
          end
          polygon.push(e) unless shared
        end
      end

      bad_triangles.each do |tri|
        triangles.delete(tri)
      end

      polygon.each do |e|
        triangles << Triangle.new([e[0], e[1], pnt])
      end
    end

    super_tri.vertex.each do |vtx|
      triangles.delete_if { |tri| tri.has_vertex(vtx) }
    end

    indices = []
    triangles.each do |tri|
      indices << [points_original.index(tri.vertex[0]), points_original.index(tri.vertex[1]), points_original.index(tri.vertex[2])]
    end

    return indices , triangles
  end

end

if __FILE__ == $0
  points = []

  points << RVec2.new(0.0, 0.0)
  points << RVec2.new(1.0, 0.0)
  points << RVec2.new(-1.0, 0.0)
  points << RVec2.new(0.0, 1.0)
  points << RVec2.new(0.0, -1.0)

  tri_indices = DelaunayTriangulation.calculate(points)
  tri_indices.each_with_index do |indices, i|
    puts "Triangle(#{i}) : (#{points[indices[0]]}, #{points[indices[1]]}, #{points[indices[2]]})\t"
  end
end
