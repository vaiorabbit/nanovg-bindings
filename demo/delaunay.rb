require 'rmath3d/rmath3d_plain'
include RMath3D

require_relative 'minicircle'

class Triangle
  attr_accessor :vertex, :edge
  def initialize(vtx)
    @vertex = vtx
    @edge = [[@vertex[0], @vertex[1]],
             [@vertex[1], @vertex[2]],
             [@vertex[2], @vertex[0]]]
  end

  def same_edge(idx, other_edge)
    if ( (@edge[idx][0] == other_edge[0] && @edge[idx][1] == other_edge[1]) ||
         (@edge[idx][1] == other_edge[0] && @edge[idx][0] == other_edge[1]) )
      return true
    end
    return false
  end

  def has_edge(other_edge)
    @edge.length.times do |idx|
      return true if same_edge(idx, other_edge)
    end
    return false
  end

  def has_vertex(pnt)
    @vertex.each do |vtx|
      return true if vtx == pnt
    end
    return false
  end

  def ==(other_tri)
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
    r, c = SmallestEnclosingCircle.circumcircle(@vertex[0], @vertex[1], @vertex[2])
    return (point - c).getLengthSq < r**2
  end
end


module Triangulation

  def self.calculate(points_original)
    points = points_original.dup
    triangles = []
    incircle_r, incircle_c = SmallestEnclosingCircle.calculate(points)

    st_hle = Math.sqrt(3) * incircle_r # half length of super triangle's edge
    super_tri = Triangle.new([RVec2.new(-st_hle, -incircle_r) + incircle_c,
                              RVec2.new(st_hle, -incircle_r) + incircle_c,
                              RVec2.new(0.0, Math.sqrt(incircle_r*incircle_r + st_hle*st_hle)) + incircle_c
                             ])

    triangles << super_tri

    while points.length > 0
      pnt = points.pop

      candidates = []
      triangles.each do |tri|
        candidates << tri if tri.circumcircle_contains(pnt)
      end

      edges = []
      candidates.each do |tri|
        tri.edge.each do |e|
          edges.push(e)
        end
        triangles.delete(tri)
        triangles << Triangle.new([tri.vertex[0], tri.vertex[1], pnt])
        triangles << Triangle.new([tri.vertex[1], tri.vertex[2], pnt])
        triangles << Triangle.new([tri.vertex[2], tri.vertex[0], pnt])
      end

      while not edges.empty?
        edge = edges.pop
        commons = []
        triangles.each do |tri|
          commons << tri if tri.has_edge(edge)
        end
        next if commons.length < 2

        tri_ABC = commons[0]
        tri_ABD = commons[1]
        if tri_ABC == tri_ABD
          triangles.delete(tri_ABC)
          triangles.delete(tri_ABD)
          next
        end

        pnt_A = edge[0]
        pnt_B = edge[1]
        pnt_C = tri_ABC.non_edge_vertex(edge)
        pnt_D = tri_ABD.non_edge_vertex(edge)

        if tri_ABC.circumcircle_contains(pnt_D)
          triangles.delete(commons[0])
          triangles.delete(commons[1])
          triangles << Triangle.new([pnt_A, pnt_C, pnt_D]) # tri_ACD
          triangles << Triangle.new([pnt_B, pnt_C, pnt_D]) # tri_BCD
          3.times do |idx|
            edges << tri_ABC.edge[idx] unless tri_ABC.same_edge(idx, edge)
            edges << tri_ABD.edge[idx] unless tri_ABD.same_edge(idx, edge)
          end
        end
      end # while not edges.empty?
    end # while points.length > 0

    super_tri.vertex.each do |vtx|
      triangles.delete_if { |tri| tri.has_vertex(vtx) }
    end

    indices = []
    triangles.each do |tri|
      indices << [points_original.index(tri.vertex[0]), points_original.index(tri.vertex[1]), points_original.index(tri.vertex[2])]
    end

    return indices #, triangles
  end

end

if __FILE__ == $0
  require 'pp'
  points = []

  points << RVec2.new(0.0, 0.0)
  points << RVec2.new(1.0, 0.0)
  points << RVec2.new(-1.0, 0.0)
  points << RVec2.new(0.0, 1.0)
  points << RVec2.new(0.0, -1.0)
  points << RVec2.new(0.0, 0.3)

  tri_indices = Triangulation.calculate(points)
  tri_indices.each_with_index do |indices, i|
    puts "Triangle(#{i}) : (#{points[indices[0]]}, #{points[indices[1]]}, #{points[indices[2]]})\t"
  end
end
