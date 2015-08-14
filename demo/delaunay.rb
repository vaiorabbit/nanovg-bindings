# coding: utf-8
# Ref.: https://en.wikipedia.org/wiki/Bowyer–Watson_algorithm
require 'rmath3d/rmath3d_plain'
include RMath3D

require_relative 'minicircle'
require_relative 'triangle'

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
