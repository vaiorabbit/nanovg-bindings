# coding: utf-8
require 'rmath3d/rmath3d_plain'
include RMath3D

require_relative 'delaunay'
require_relative 'convex_hull'

class VoronoiCell

  attr_accessor :center_index # index from points_original
  attr_accessor :vertex_indices # indices from triangles
  attr_accessor :bounded
  attr_accessor :ray_directions # RVec2[2]
  attr_accessor :ray_origin_indices # [2], indices from vertex_indices

  def initialize
    @center_index = -1
    @vertex_indices = []
    @bounded = true
    @ray_directions = []
    @ray_origin_indices = []
  end

end


module VoronoiDiagram

  def self.calculate(points_original)
    return self.calculate_VDBDT(points_original)
  end

  # Ref. Sun et al., Voronoi Diagram Generation Algorithm based on Delaunay Triangulation http://ojs.academypublisher.com/index.php/jsw/article/view/jsw0903777784
  def self.calculate_VDBDT(points_original)
    points = points_original.dup
    hull_indices = ConvexHull.calculate(points)
    hull_edges = []
    hull_indices.length.times do |i|
      hull_edges << [points[hull_indices[i]], points[hull_indices[(i+1) % hull_indices.length]]]
    end

    tv_indices, triangles = Triangulation.calculate(points)
    triangle_indices = (0...triangles.length).to_a

    voronoi_cells = []

    for point_index in 0...points.length do
      vc = VoronoiCell.new
      vc.center_index = point_index

      vtx = points[point_index]
      edges = []
      tis = triangle_indices.select { |ti| triangles[ti].has_vertex(vtx) }
      tis.each do |ti|
        tri = triangles[ti]
        3.times do |edge_index|
          edge = tri.edge[edge_index]
          edges << edge if edge[0] == vtx || edge[1] == vtx
        end
      end

      is_hull_vertex = hull_indices.include?(point_index)
      if is_hull_vertex
        vc.bounded = false
        edges.each do |edge|
          is_hull_edge = hull_edges.any? { |hull_edge|
            (hull_edge[0] == edge[0] && hull_edge[1] == edge[1]) || (hull_edge[1] == edge[0] && hull_edge[0] == edge[1])
          }
          if is_hull_edge
            tri = triangles.select { |t| t.has_edge(edge) }.first
            vc.ray_origin_indices << triangles.find_index(tri)
            vc.ray_directions << RVec2.new(1.0, 0.0) # TODO : calculate outward direction
          else
            tris = triangles.select { |t| t.has_edge(edge) } # length == 2
            ti0 = triangles.find_index(tris[0])
            ti1 = triangles.find_index(tris[1])
            vc.vertex_indices << ti0 << ti1
          end
        end
        vc.vertex_indices.uniq!
      else
        tis.each do |ti|
          vc.vertex_indices << ti
        end
      end
      voronoi_cells << vc
    end

    # clockwise sort http://stackoverflow.com/questions/6989100/sort-points-in-clockwise-order
    voronoi_cells.each do |vc|
      center = RVec2.new(0.0, 0.0)
      vc.vertex_indices.each do |vi|
        center += triangles[vi].cc
      end
      center *= 1.0 / vc.vertex_indices.length
      vc.vertex_indices.sort! do |i, j|
        r = 0
        pnt_i = triangles[i].cc
        pnt_j = triangles[j].cc
        r = +1 if pnt_i.x >= center.x && pnt_j.x  < center.x
        r = -1 if pnt_i.x  < center.x && pnt_j.x >= center.x
        if pnt_i.x == center.x && pnt_j.x == center.x
          if pnt_i.y >= center.y || pnt_j.y >= center.y
            r = pnt_i.y > pnt_j.y ? +1 : -1
          end
          r = pnt_j.y > pnt_i.y ? +1 : -1
        end

        if r == 0
          det = RVec2.cross(pnt_i - center, pnt_j - center)
          r = +1 if det > 0
          r = -1 if det < 0
        end

        if r == 0
          d1 = (pnt_i - center.x).getLengthSq
          d2 = (pnt_j - center.x).getLengthSq
          r = d1 > d2 ? +1 : -2
        end
        r
      end
    end

    voronoi_vertices = []
    triangles.each do |tri|
      voronoi_vertices << tri.cc
    end

    return voronoi_cells, voronoi_vertices
  end

end

if __FILE__ == $0
  points = []

  points << RVec2.new(0.0, 0.0)
  points << RVec2.new(1.0, 0.0)
  points << RVec2.new(-1.0, 0.0)
  points << RVec2.new(0.0, 1.0)
  points << RVec2.new(0.0, -1.0)

  voronoi_cells, voronoi_vertices = VoronoiDiagram.calculate(points)
  pp voronoi_cells, voronoi_vertices
end
