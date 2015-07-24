# Ref.:
# http://www.redblobgames.com/grids/hexagons/
# http://www.redblobgames.com/grids/hexagons/implementation.html

class Hex

  attr_accessor :q, :r, :s

  def initialize(q, r, s = -q - r)
    @q = q
    @r = r
    @s = s
  end

  def self.equal(a, b)
    (a.q == b.q) && (a.r == b.r) && (a.s == b.s)
  end

  def self.add(a, b)
    Hex.new(a.q + b.q, a.r + b.r, a.s + b.s)
  end

  def self.subtract(a, b)
    Hex.new(a.q - b.q, a.r - b.r, a.s - b.s)
  end

  def self.scale(a, k)
    Hex.new(a.q * k, a.r * k, a.s * k)
  end


  @@directions = [
    Hex.new(1, 0, -1),
    Hex.new(1, -1, 0),
    Hex.new(0, -1, 1),
    Hex.new(-1, 0, 1),
    Hex.new(-1, 1, 0),
    Hex.new(0, 1, -1)
  ]

  def self.direction(dir)
    @@directions[dir]
  end

  def neighbor(dir)
    Hex.add(self, Hex.direction(dir))
  end

  @@diagonals = [
    Hex.new(2, -1, -1),
    Hex.new(1, -2, 1),
    Hex.new(-1, -1, 2),
    Hex.new(-2, 1, 1),
    Hex.new(-1, 2, -1),
    Hex.new(1, 1, -2)
  ]

  def diagonal_neighbor(dir)
    Hex.add(self, @@diagonals[dir])
  end


  def length
    ((@q.abs + @r.abs + @s.abs) / 2).to_i
  end

  def self.distance(a, b)
    Hex.subtract(a, b).length
  end


  def self.round(h)
    q = h.q.round.to_i
    r = h.r.round.to_i
    s = h.s.round.to_i
    q_diff = (q - h.q).abs
    r_diff = (r - h.r).abs
    s_diff = (s - h.s).abs
    if q_diff > r_diff and q_diff > s_diff
      q = -r - s
    else
      if r_diff > s_diff
        r = -q - s
      else
        s = -q - r
      end
    end
    return Hex.new(q, r, s)
  end

  def round
    Hex.round(self)
  end

  def self.lerp(a, b, t)
    Hex.new(a.q + (b.q - a.q) * t, a.r + (b.r - a.r) * t, a.s + (b.s - a.s) * t)
  end


  def self.linedraw(a, b)
    n = Hex.distance(a, b)
    results = []
    step = 1.0 / [n, 1].max
    (0..n).each do |i|
      results << Hex.lerp(a, b, step * i).round
    end
    return results
  end

end


class OffsetCoord
  EVEN =  1
  ODD  = -1

  attr_accessor :col, :row
  def initialize(col, row)
    @col = col
    @row = row
  end

  def self.equal(a, b)
    (a.col == b.col) && (a.row == b.row)
  end

  def self.qoffset_from_cube(offset, h) # h : Hex
    col = h.q
    row = h.r + ((h.q + offset * (h.q & 1)) / 2).to_i
    OffsetCoord.new(col, row)
  end

  def self.qoffset_to_cube(offset, h) # h : OffsetCoord
    q = h.col
    r = h.row - ((h.col + offset * (h.col & 1)) / 2).to_i
    s = -q - r
    Hex.new(q, r, s)
  end

  def self.roffset_from_cube(offset, h) # h : Hex
    col = h.q + ((h.r + offset * (h.r & 1)) / 2).to_i
    row = h.r
    OffsetCoord.new(col, row)
  end

  def self.roffset_to_cube(offset, h) # h : OffsetCoord
    q = h.col - ((h.row + offset * (h.row & 1)) / 2).to_i
    r = h.row
    s = -q - r
    Hex.new(q, r, s)
  end

end



class Orientation

  attr_reader :f0, :f1, :f2, :f3, :b0, :b1, :b2, :b3, :start_angle
  def initialize(f0, f1, f2, f3, b0, b1, b2, b3, start_angle)
    @f0 = f0
    @f1 = f1
    @f2 = f2
    @f3 = f3
    @b0 = b0
    @b1 = b1
    @b2 = b2
    @b3 = b3
    @start_angle = start_angle
  end

end

class Point

  attr_accessor :x, :y
  def initialize(x, y)
    @x = x
    @y = y
  end

end

class Layout

  POINTY = Orientation.new(Math.sqrt(3.0), Math.sqrt(3.0) / 2.0, 0.0, 3.0 / 2.0, Math.sqrt(3.0) / 3.0, -1.0 / 3.0, 0.0, 2.0 / 3.0, 0.5)
  FLAT = Orientation.new(3.0 / 2.0, 0.0, Math.sqrt(3.0) / 2.0, Math.sqrt(3.0), 2.0 / 3.0, 0.0, -1.0 / 3.0, Math.sqrt(3.0) / 3.0, 0.0)

  attr_accessor :orientation, :size, :origin
  def initialize(orientation, size, origin) # orientation : POINTY or FLAT, size and origin : Point
    @orientation = orientation
    @size = size
    @origin = origin
  end

  def hex_to_pixel(h) # h : Hex
    m = @orientation
    x = (m.f0 * h.q + m.f1 * h.r) * @size.x
    y = (m.f2 * h.q + m.f3 * h.r) * @size.y
    return Point.new(x + @origin.x, y + @origin.y)
  end

  def pixel_to_hex(p) # p : Point
    m = @orientation
    pt = Point.new((p.x - @origin.x) / @size.x, (p.y - @origin.y) / @size.y)
    q = m.b0 * pt.x + m.b1 * pt.y
    r = m.b2 * pt.x + m.b3 * pt.y
    return Hex.new(q, r, -q - r)
  end

  def corner_offset(corner)
    angle = 2.0 * Math::PI * (corner + @orientation.start_angle) / 6
    return Point.new(@size.x * Math.cos(angle), @size.y * Math.sin(angle))
  end
  private :corner_offset

  def polygon_corners(h) # h : Hex
    corners = []
    center = hex_to_pixel(h)
    6.times do |i|
      offset = corner_offset(i)
      corners << Point.new(center.x + offset.x, center.y + offset.y)
    end
    return corners
  end

end

if __FILE__ == $0

  # Ref.: http://qiita.com/repeatedly/items/727b08599d87af7fa671
  require 'test/unit'

  class TestHex < Test::Unit::TestCase
    def self.startup;  end
    def self.shutdown; end

    def setup;    end
    def cleanup;  end
    def teardown; end

    def test_arithmetic
      assert_true(Hex.equal(Hex.new(4, -10, 6), Hex.add(Hex.new(1, -3, 2), Hex.new(3, -7, 4))), "Hex.add")
      assert_true(Hex.equal(Hex.new(-2, 4, -2), Hex.subtract(Hex.new(1, -3, 2), Hex.new(3, -7, 4))), "Hex.subtract")
    end

    def test_direction
      assert_true(Hex.equal(Hex.new(0, -1, 1), Hex.direction(2)), "Hex.direction")
    end

    def test_neighbor
      assert_true(Hex.equal(Hex.new(1, -3, 2), Hex.new(1, -2, 1).neighbor(2)), "Hex.neighbor")
    end

    def test_diagonal
      assert_true(Hex.equal(Hex.new(-1, -1, 2), Hex.new(1, -2, 1).diagonal_neighbor(3)), "Hex.diagonal_neighbor")
    end

    def test_distance
      assert_equal(7, Hex.distance(Hex.new(3, -7, 4), Hex.new(0, 0, 0)), "Hex.distance")
    end

    def test_round
      a = Hex.new(0, 0, 0)
      b = Hex.new(1, -1, 0)
      c = Hex.new(0, -1, 1)
      assert_true(Hex.equal(Hex.new(5, -10, 5), Hex.round(Hex.lerp(Hex.new(0, 0, 0), Hex.new(10, -20, 10), 0.5))), "Hex.round 1")
      assert_true(Hex.equal(a, (Hex.lerp(a, b, 0.499)).round), "Hex.round 2")
      assert_true(Hex.equal(b, (Hex.lerp(a, b, 0.501)).round), "Hex.round 3")
      assert_true(Hex.equal(a, (Hex.new(a.q * 0.4 + b.q * 0.3 + c.q * 0.3, a.r * 0.4 + b.r * 0.3 + c.r * 0.3, a.s * 0.4 + b.s * 0.3 + c.s * 0.3)).round), "Hex.round 4")
      assert_true(Hex.equal(c, (Hex.new(a.q * 0.3 + b.q * 0.3 + c.q * 0.4, a.r * 0.3 + b.r * 0.3 + c.r * 0.4, a.s * 0.3 + b.s * 0.3 + c.s * 0.4)).round), "Hex.round 5")
    end

    def test_linedraw
      ary0 = [Hex.new(0, 0, 0), Hex.new(0, -1, 1), Hex.new(0, -2, 2), Hex.new(1, -3, 2), Hex.new(1, -4, 3), Hex.new(1, -5, 4)]
      ary1 = Hex.linedraw(Hex.new(0, 0, 0), Hex.new(1, -5, 4))
      assert_equal(ary0.length, ary1.length)
      ary0.length.times do |i|
        assert_true(Hex.equal(ary0[i], ary1[i]), "Hex.linedraw")
      end
    end

    def test_layout
      h = Hex.new(3, 4, -7)
      flat = Layout.new(Layout::FLAT, Point.new(10, 15), Point.new(35, 71))
      assert_true(Hex.equal(h, Hex.round(flat.pixel_to_hex( flat.hex_to_pixel(h) ))), "layout")
      pointy = Layout.new(Layout::POINTY, Point.new(10, 15), Point.new(35, 71))
      assert_true(Hex.equal(h, Hex.round(pointy.pixel_to_hex( pointy.hex_to_pixel(h) ))), "layout")
    end

    def test_conversion_roundtrip
      a = Hex.new(3, 4, -7)
      b = OffsetCoord.new(1, -3)
      assert_true(Hex.equal(a, OffsetCoord.qoffset_to_cube(OffsetCoord::EVEN, OffsetCoord.qoffset_from_cube(OffsetCoord::EVEN, a))), "conversion_roundtrip even-q")
      assert_true(OffsetCoord.equal(b, OffsetCoord.qoffset_from_cube(OffsetCoord::EVEN, OffsetCoord.qoffset_to_cube(OffsetCoord::EVEN, b))), "conversion_roundtrip even-q");

      assert_true(Hex.equal(a, OffsetCoord.qoffset_to_cube(OffsetCoord::ODD, OffsetCoord.qoffset_from_cube(OffsetCoord::ODD, a))), "conversion_roundtrip odd-q")
      assert_true(OffsetCoord.equal(b, OffsetCoord.qoffset_from_cube(OffsetCoord::ODD, OffsetCoord.qoffset_to_cube(OffsetCoord::ODD, b))), "conversion_roundtrip odd-q");

      assert_true(Hex.equal(a, OffsetCoord.roffset_to_cube(OffsetCoord::EVEN, OffsetCoord.roffset_from_cube(OffsetCoord::EVEN, a))), "conversion_roundtrip even-r")
      assert_true(OffsetCoord.equal(b, OffsetCoord.roffset_from_cube(OffsetCoord::EVEN, OffsetCoord.roffset_to_cube(OffsetCoord::EVEN, b))), "conversion_roundtrip even-r");

      assert_true(Hex.equal(a, OffsetCoord.roffset_to_cube(OffsetCoord::ODD, OffsetCoord.roffset_from_cube(OffsetCoord::ODD, a))), "conversion_roundtrip odd-r")
      assert_true(OffsetCoord.equal(b, OffsetCoord.roffset_from_cube(OffsetCoord::ODD, OffsetCoord.roffset_to_cube(OffsetCoord::ODD, b))), "conversion_roundtrip odd-r");
    end

    def test_offset_from_cube
      assert_true(OffsetCoord.equal(OffsetCoord.new(1, 3), OffsetCoord.qoffset_from_cube(OffsetCoord::EVEN, Hex.new(1, 2, -3))), "offset_from_cube even-q");
      assert_true(OffsetCoord.equal(OffsetCoord.new(1, 2), OffsetCoord.qoffset_from_cube(OffsetCoord::ODD, Hex.new(1, 2, -3))), "offset_from_cube odd-q");
    end

    def test_offset_to_cube
      assert_true(Hex.equal(Hex.new(1, 2, -3), OffsetCoord.qoffset_to_cube(OffsetCoord::EVEN, OffsetCoord.new(1, 3))), "offset_to_cube even-")
      assert_true(Hex.equal(Hex.new(1, 2, -3), OffsetCoord.qoffset_to_cube(OffsetCoord::ODD, OffsetCoord.new(1, 2))), "offset_to_cube odd-q")
    end

  end

end
