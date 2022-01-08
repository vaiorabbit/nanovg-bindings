class Scene
  attr_reader :name
  def initialize(name); @name = name; end
  def init; end
  def term; end
  def render(vg, width, height, dt = 0.0); end
end

################################################################################

class GridScene < Scene

  def initialize(name)
    super
    @time = 0.0
  end

  def render(vg, width, height, dt = 0.0)
    @time += dt
    scale = Math.sin(@time) + 1.0
    div = 20
    lw = [1.5 * scale, 0.5].max
    nx = (width.to_i / div)
    ny = (height.to_i / div)
    NVG.Save(vg)
    nx.times do |i|
      x = div * i
      NVG.StrokeWidth(vg, lw)
      NVG.StrokeColor(vg, NVG.RGBA(255,255,255,255))
      NVG.BeginPath(vg)
      NVG.MoveTo(vg, x, 0.0)
      NVG.LineTo(vg, x, height)
      NVG.Stroke(vg)
    end
    ny.times do |i|
      y = div * i
      NVG.StrokeWidth(vg, lw)
      NVG.StrokeColor(vg, NVG.RGBA(255,255,255,255))
      NVG.BeginPath(vg)
      NVG.MoveTo(vg, 0, y)
      NVG.LineTo(vg, width, y)
      NVG.Stroke(vg)
    end
    NVG.Restore(vg)
  end

end

################################################################################

class TriangleScene < Scene

  def initialize(name)
    super
    @time = 0.0
  end

  def render(vg, width, height, dt = 0.0)
    @time += dt
    hue = Math.sin(@time * 0.12)
    x = width - width/2.0
    y = height - height/2.0

    NVG.Save(vg)

    NVG.StrokeWidth(vg, 2.0)
    NVG.StrokeColor(vg, NVG.RGBA(255,255,255,192))

    NVG.Translate(vg, x,y)
    NVG.Rotate(vg, hue*Math::PI*2)

    r1 = (width < height ? width : height) * 0.5 - 5.0
    r0 = r1 - 20.0
    r = r0 - 6
    ax = Math.cos(120.0/180.0*Math::PI) * r
    ay = Math.sin(120.0/180.0*Math::PI) * r
    bx = Math.cos(-120.0/180.0*Math::PI) * r
    by = Math.sin(-120.0/180.0*Math::PI) * r

    NVG.BeginPath(vg)
    NVG.MoveTo(vg, r,0)
    NVG.LineTo(vg, ax,ay)
    NVG.LineTo(vg, bx,by)
    NVG.ClosePath(vg)
    paint = NVG.LinearGradient(vg, r,0, ax,ay, NVG.HSLA(hue,1.0,0.5,255), NVG.RGBA(255,255,255,255))
    NVG.FillPaint(vg, paint)
    NVG.Fill(vg)
    paint = NVG.LinearGradient(vg, (r+ax)*0.5,(0+ay)*0.5, bx,by, NVG.RGBA(0,0,0,0), NVG.RGBA(0,0,0,255))
    NVG.FillPaint(vg, paint)
    NVG.Fill(vg)
    NVG.StrokeColor(vg, NVG.RGBA(0,0,0,64))
    NVG.Stroke(vg)

    NVG.Restore(vg)
  end

end

################################################################################

module Arrow

  def self.render_simple(vg, src_x, src_y, dst_x, dst_y, outer_line: true, inner_fill: true,
                         color: NVG.RGBA(255,255,255,255), gradient_start: color, gradient_end: color)
    end_base_x = 0.0
    end_base_y = 0.0
    tip_base_x = 1.0
    tip_base_y = 0.0
    l = tip_base_x - end_base_x
    hl = l / 3.0
    bl = l - hl
    hw = 2.0 * hl * Math.tan(15.0*Math::PI / 180.0)
    bw = hw / 2.0
    arrow_length_base = Math.sqrt((end_base_x - tip_base_x)**2 + (end_base_y - tip_base_y)**2)

    arrow_length = Math.sqrt((dst_x - src_x)**2 + (dst_y - src_y)**2)
    scaling = arrow_length / arrow_length_base
    theta = Math.atan2( (dst_y - src_y)/arrow_length, (dst_x - src_x) / arrow_length )

    NVG.Save(vg)
    NVG.Translate(vg, src_x,src_y)
    NVG.Rotate(vg, theta)
    NVG.Scale(vg, scaling, scaling)

    NVG.BeginPath(vg)
    NVG.MoveTo(vg, end_base_x, end_base_y)
    NVG.LineTo(vg, end_base_x, end_base_y + bw / 2)
    NVG.LineTo(vg, end_base_x + bl, end_base_y + bw / 2)
    NVG.LineTo(vg, end_base_x + bl, end_base_y + hw / 2)
    NVG.LineTo(vg, end_base_x + l, end_base_y)
    NVG.LineTo(vg, end_base_x + bl, end_base_y - hw / 2)
    NVG.LineTo(vg, end_base_x + bl, end_base_y - bw / 2)
    NVG.LineTo(vg, end_base_x, end_base_y - bw / 2)
    NVG.ClosePath(vg)

    # Outer Line
    if outer_line
      NVG.StrokeWidth(vg, 5 / scaling)
      NVG.StrokeColor(vg, color)
      NVG.Stroke(vg)
    end

    # Inner Area
    if inner_fill
      paint = NVG.LinearGradient(vg, end_base_x,end_base_y, end_base_x+l,end_base_y, gradient_start, gradient_end)
      NVG.FillPaint(vg, paint)
      NVG.Fill(vg)
    end

    NVG.Restore(vg)
  end

  def self.render(vg, src_x, src_y, dst_x, dst_y, head_length: 100.0, head_width: head_length/3, shaft_width: head_width/2,
                  outer_line: true, inner_fill: true, outer_width: 2.5, outer_color: NVG.RGBA(255,255,255,255), gradient_start: NVG.RGBA(255,255,255,0), gradient_end: NVG.RGBA(255,255,255,255))

    arrow_length = Math.sqrt((dst_x - src_x)**2 + (dst_y - src_y)**2)
    bottom_x = 0.0
    bottom_y = 0.0
    toptip_x = arrow_length
    toptip_y = 0.0
    shaft_length = arrow_length - head_length
    arrow_length_base = Math.sqrt((bottom_x - toptip_x)**2 + (bottom_y - toptip_y)**2)

    theta = Math.atan2( (dst_y - src_y)/arrow_length, (dst_x - src_x) / arrow_length )

    NVG.Save(vg)
    NVG.Translate(vg, src_x,src_y)
    NVG.Rotate(vg, theta)

    NVG.BeginPath(vg)
    NVG.MoveTo(vg, bottom_x, bottom_y)
    NVG.LineTo(vg, bottom_x, bottom_y + shaft_width / 2)
    NVG.LineTo(vg, bottom_x + shaft_length, bottom_y + shaft_width / 2)
    NVG.LineTo(vg, bottom_x + shaft_length, bottom_y + head_width / 2)
    NVG.LineTo(vg, bottom_x + arrow_length, bottom_y)
    NVG.LineTo(vg, bottom_x + shaft_length, bottom_y - head_width / 2)
    NVG.LineTo(vg, bottom_x + shaft_length, bottom_y - shaft_width / 2)
    NVG.LineTo(vg, bottom_x, bottom_y - shaft_width / 2)
    NVG.ClosePath(vg)

    # Outer Line
    if outer_line
      NVG.StrokeWidth(vg, outer_width)
      NVG.StrokeColor(vg, outer_color)
      NVG.Stroke(vg)
    end

    # Inner Area
    if inner_fill
      paint = NVG.LinearGradient(vg, bottom_x,bottom_y, bottom_x+arrow_length,bottom_y, gradient_start, gradient_end)
      NVG.FillPaint(vg, paint)
      NVG.Fill(vg)
    end

    NVG.Restore(vg)
  end

end

class ArrowScene < Scene

  def initialize(name)
    super
    @time = 0.0
  end

  def render(vg, width, height, dt = 0.0)
    @time += dt
    x = width - width/2.0
    y = height - height/2.0

    NVG.Save(vg)

    src_x = 100
    src_y = 500
    dst_x = 900
    dst_y = 100
  # Arrow.render_simple(vg, src_x, src_y, dst_x, dst_y)
    Arrow.render(vg, src_x, src_y, dst_x, dst_y)

    NVG.BeginPath(vg)
    NVG.Circle(vg, src_x,src_y, 10.0)
    paint = NVG.RadialGradient(vg, src_x,src_y, 0.1,10, NVG.RGBA(0,255,0,192), NVG.RGBA(0,255,0,0))
    NVG.FillPaint(vg, paint)
    NVG.Fill(vg)

    NVG.BeginPath(vg)
    NVG.Circle(vg, dst_x,dst_y, 10.0)
    paint = NVG.RadialGradient(vg, dst_x,dst_y, 0.1,10, NVG.RGBA(255,0,0,192), NVG.RGBA(255,0,0,0))
    NVG.FillPaint(vg, paint)
    NVG.Fill(vg)

    NVG.Restore(vg)
  end

end

################################################################################

class DragonCurve

  attr_accessor :base_x, :base_y

  def initialize(base_x = 0, base_y = 0)
    @base_x = base_x
    @base_y = base_y
  end

  def split(vg, order, dx, dy, sign)
    if order == 0
      NVG.LineTo(vg, @base_x+dx, @base_y+dy)
      @base_x += dx
      @base_y += dy
    else
      split(vg, order-1, (dx-sign*dy)/2.0, (dy+sign*dx)/2.0,  1.0)
      split(vg, order-1, (dx+sign*dy)/2.0, (dy-sign*dx)/2.0, -1.0)
    end
  end

end

class DragonCurveScene < Scene

  # attr_accessor :should_save

  def initialize(name)
    super
    @time = 0.0
    @dc = DragonCurve.new
    @order = 0
    @order_max = 17
    @ascending = true
    # @should_save = true
  end

  def render(vg, width, height, dt = 0.0)
    @time += dt
    x = width - width/2.0
    y = height - height/2.0

    NVG.Save(vg)

    src_x = 250
    src_y = 200
    dx = 600
    dy = 0

    if @time > 0.50
      # @should_save = true
      @order += @ascending ? 1 : -1
      if @order > @order_max
        @order = @order_max
        @ascending = false
      elsif @order < 0
        @order = 0
        @ascending = true
      end
      @time = 0.0
    end

    @dc.base_x = src_x
    @dc.base_y = src_y

    NVG.BeginPath(vg)
    NVG.MoveTo(vg, @dc.base_x, @dc.base_y)
    @dc.split(vg, @order, dx, dy, 1.0)

    # Outer Line
    order_crit = 9
    w_max = 4.0
    w_min = 1.0
    width = if @order >= order_crit
              t = (@order - order_crit) * (w_min - w_max) / (@order_max - order_crit) + w_max
            else
              w_max
            end
    NVG.StrokeWidth(vg, width)
    NVG.StrokeColor(vg, NVG.RGBA(160,192,255,255))
    NVG.Stroke(vg)

    # Start
    NVG.BeginPath(vg)
    NVG.Circle(vg, src_x,src_y, 10.0)
    paint = NVG.RadialGradient(vg, src_x,src_y, 0.1,10, NVG.RGBA(0,255,0,192), NVG.RGBA(0,255,0,0))
    NVG.FillPaint(vg, paint)
    NVG.Fill(vg)

    # End
    NVG.BeginPath(vg)
    NVG.Circle(vg, src_x+dx,src_y+dy, 10.0)
    paint = NVG.RadialGradient(vg, src_x+dx,src_y+dy, 0.1,10, NVG.RGBA(255,0,0,192), NVG.RGBA(255,0,0,0))
    NVG.FillPaint(vg, paint)
    NVG.Fill(vg)

    NVG.Restore(vg)
  end

end

################################################################################

class HilbertCurve

  attr_accessor :base_x, :base_y, :width, :order

  DIR_UP    = 0
  DIR_LEFT  = 1
  DIR_DOWN  = 2
  DIR_RIGHT = 3

  def initialize(base_x = 0, base_y = 0, width = 100, order = 0)
    @base_x = base_x
    @base_y = base_y
    @current_x = base_x
    @current_y = base_y
    @width = width
    @order = order
  end

  # Ref.: http://www.compuphase.com/hilbert.htm
  #       http://math.stackexchange.com/questions/53089/hilbert-curve-understanding-the-original-article
  def split(vg, stack = @order, dir = DIR_UP)
    len = (@width / 2.0) * 2.0**(-@order)
    if stack == @order
      case dir
      when DIR_UP, DIR_LEFT
        @current_x = @base_x + len*0.5
        @current_y = @base_y + len*0.5
      when DIR_DOWN, DIR_RIGHT
        @current_x = @base_x + len*1.5
        @current_y = @base_y + len*1.5
      end
      NVG.MoveTo(vg, @current_x, @current_y)
    end

    if stack == 0
      case dir
      when DIR_LEFT
        NVG.LineTo(vg, @current_x+len, @current_y); @current_x += len # R
        NVG.LineTo(vg, @current_x, @current_y+len); @current_y += len # D
        NVG.LineTo(vg, @current_x-len, @current_y); @current_x -= len # L
      when DIR_RIGHT
        NVG.LineTo(vg, @current_x-len, @current_y); @current_x -= len # L
        NVG.LineTo(vg, @current_x, @current_y-len); @current_y -= len # U
        NVG.LineTo(vg, @current_x+len, @current_y); @current_x += len # R
      when DIR_UP
        NVG.LineTo(vg, @current_x, @current_y+len); @current_y += len # D
        NVG.LineTo(vg, @current_x+len, @current_y); @current_x += len # R
        NVG.LineTo(vg, @current_x, @current_y-len); @current_y -= len # U
      when DIR_DOWN
        NVG.LineTo(vg, @current_x, @current_y-len); @current_y -= len # U
        NVG.LineTo(vg, @current_x-len, @current_y); @current_x -= len # L
        NVG.LineTo(vg, @current_x, @current_y+len); @current_y += len # D
      end
    else
      case dir
      when DIR_LEFT
        split(vg, stack-1, DIR_UP)
        NVG.LineTo(vg, @current_x+len, @current_y); @current_x += len # R
        split(vg, stack-1, DIR_LEFT)
        NVG.LineTo(vg, @current_x, @current_y+len); @current_y += len # D
        split(vg, stack-1, DIR_LEFT)
        NVG.LineTo(vg, @current_x-len, @current_y); @current_x -= len # L
        split(vg, stack-1, DIR_DOWN)
      when DIR_RIGHT
        split(vg, stack-1, DIR_DOWN)
        NVG.LineTo(vg, @current_x-len, @current_y); @current_x -= len # L
        split(vg, stack-1, DIR_RIGHT)
        NVG.LineTo(vg, @current_x, @current_y-len); @current_y -= len # U
        split(vg, stack-1, DIR_RIGHT)
        NVG.LineTo(vg, @current_x+len, @current_y); @current_x += len # R
        split(vg, stack-1, DIR_UP)
      when DIR_UP
        split(vg, stack-1, DIR_LEFT)
        NVG.LineTo(vg, @current_x, @current_y+len); @current_y += len # D
        split(vg, stack-1, DIR_UP)
        NVG.LineTo(vg, @current_x+len, @current_y); @current_x += len # R
        split(vg, stack-1, DIR_UP)
        NVG.LineTo(vg, @current_x, @current_y-len); @current_y -= len # U
        split(vg, stack-1, DIR_RIGHT)
      when DIR_DOWN
        split(vg, stack-1, DIR_RIGHT)
        NVG.LineTo(vg, @current_x, @current_y-len); @current_y -= len # U
        split(vg, stack-1, DIR_DOWN)
        NVG.LineTo(vg, @current_x-len, @current_y); @current_x -= len # L
        split(vg, stack-1, DIR_DOWN)
        NVG.LineTo(vg, @current_x, @current_y+len); @current_y += len # D
        split(vg, stack-1, DIR_LEFT)
      end
    end
  end

end

class HilbertCurveScene < Scene

  # attr_accessor :should_save

  def initialize(name)
    super
    @time = 0.0
    @hc = HilbertCurve.new
    @order = 0
    @order_max = 8
    @ascending = true
    # @should_save = true
  end

  def render(vg, width, height, dt = 0.0)
    @time += dt

    src_x = 220
    src_y = 20
    wh = 560

    if @time > 1.0
      # @should_save = true
      @order += @ascending ? 1 : -1
      if @order > @order_max
        @order = @order_max
        @ascending = false
      elsif @order < 0
        @order = 0
        @ascending = true
      end
      @time = 0.0
    end

    @hc.base_x = src_x
    @hc.base_y = src_y
    @hc.order = @order
    @hc.width = wh

    NVG.Save(vg)

    NVG.BeginPath(vg)
    @hc.split(vg)

    # Outer Line
    order_crit = 3
    w_max = 6.0
    w_min = 1.5
    width = if @order >= order_crit
              t = (@order - order_crit) * (w_min - w_max) / (@order_max - order_crit) + w_max
            else
              w_max
            end
    NVG.StrokeWidth(vg, width)
    NVG.LineCap(vg, NVG::SQUARE)
    NVG.StrokeColor(vg, NVG.RGBA(160,192,255,255))
    NVG.Stroke(vg)

    # Filling area
    NVG.BeginPath(vg)
    NVG.Rect(vg, @hc.base_x,@hc.base_y, @hc.width, @hc.width)
    NVG.FillColor(vg, NVG.RGBA(255,255,255,16))
    NVG.Fill(vg)

    # Start
    NVG.BeginPath(vg)
    NVG.Circle(vg, @hc.base_x,@hc.base_y, 10.0)
    paint = NVG.RadialGradient(vg, @hc.base_x,@hc.base_y, 0.1,10, NVG.RGBA(0,255,0,192), NVG.RGBA(0,255,0,0))
    NVG.FillPaint(vg, paint)
    NVG.Fill(vg)

    # End
    NVG.BeginPath(vg)
    NVG.Circle(vg, @hc.base_x+@hc.width,@hc.base_y+@hc.width, 10.0)
    paint = NVG.RadialGradient(vg, @hc.base_x+@hc.width,@hc.base_y+@hc.width, 0.1,10, NVG.RGBA(255,0,0,192), NVG.RGBA(255,0,0,0))
    NVG.FillPaint(vg, paint)
    NVG.Fill(vg)

    NVG.Restore(vg)
  end

end

################################################################################

class ZOrderCurve

  attr_accessor :base_x, :base_y, :width, :cell_count

  def initialize(base_x = 0, base_y = 0, width = 100, cell_count = 0)
    @base_x = base_x
    @base_y = base_y
    @line_base_x = base_x
    @line_base_y = base_y
    @width = width
    @cell_count = cell_count
  end

  # Ref. : Real-Time Collision Detection, Chapter 7.3.5
  def encode_2d(n)
    n = (n ^ (n <<  8)) & 0x00ff00ff
    n = (n ^ (n <<  4)) & 0x0f0f0f0f
    n = (n ^ (n <<  2)) & 0x33333333
    n = (n ^ (n <<  1)) & 0x55555555
    return n
  end

  def decode_2d(n)
    n &= 0x55555555
    n = (n ^ (n >>  1)) & 0x33333333
    n = (n ^ (n >>  2)) & 0x0f0f0f0f
    n = (n ^ (n >>  4)) & 0x00ff00ff
    n = (n ^ (n >>  8)) & 0x0000ffff
    return n
  end

  def morton_encode_2d(x, y)
    (encode_2d(y) << 1) + encode_2d(x)
  end

  def morton_decode_2d(m)
    return decode_2d(m), decode_2d(m >> 1)
  end

  def split(vg)
    segment_wh = width / @cell_count.to_f
    @line_base_x = base_x + segment_wh/2
    @line_base_y = base_y + segment_wh/2
    NVG.MoveTo(vg, @line_base_x, @line_base_y)
    n = (4 ** Math.log2(@cell_count).to_i).to_i # ex.) @cell_count==3 -> log2(2**3)==3 -> 4**3 -> n==64
    n.times do |m|
      x, y = morton_decode_2d(m)
      NVG.LineTo(vg, @line_base_x+x*segment_wh, @line_base_y+y*segment_wh)
    end

  end

end

class ZOrderCurveScene < Scene

  # attr_accessor :should_save

  def initialize(name)
    super
    @time = 0.0
    @zc = ZOrderCurve.new
    @cell_order = 1
    @cell_order_max = 9
    @ascending = true
    # @should_save = true
  end

  def render(vg, width, height, dt = 0.0)
    @time += dt

    src_x = 220
    src_y = 20
    wh = 560

    if @time > 0.2
      # @should_save = true
      @cell_order += @ascending ? 1 : -1
      if @cell_order > @cell_order_max
        @cell_order = @cell_order_max
        @ascending = false
      elsif @cell_order <= 0
        @cell_order = 1
        @ascending = true
      end
      @time = 0.0
    end

    @zc.base_x = src_x
    @zc.base_y = src_y
    @zc.cell_count = 2**@cell_order
    @zc.width = wh

    NVG.Save(vg)

    NVG.BeginPath(vg)
    @zc.split(vg)

    # Outer Line
    cell_order_crit = 4
    w_max = 6.0
    w_min = 1.0
    width = @cell_order >= cell_order_crit ? w_min : w_max

    NVG.StrokeWidth(vg, width)
    NVG.LineCap(vg, NVG::SQUARE)
    NVG.StrokeColor(vg, NVG.RGBA(160,192,255,255))
    NVG.Stroke(vg)

    # Filling area
    NVG.BeginPath(vg)
    NVG.Rect(vg, @zc.base_x,@zc.base_y, @zc.width, @zc.width)
    NVG.FillColor(vg, NVG.RGBA(255,255,255,16))
    NVG.Fill(vg)

    # Start
    NVG.BeginPath(vg)
    NVG.Circle(vg, @zc.base_x,@zc.base_y, 10.0)
    paint = NVG.RadialGradient(vg, @zc.base_x,@zc.base_y, 0.1,10, NVG.RGBA(0,255,0,192), NVG.RGBA(0,255,0,0))
    NVG.FillPaint(vg, paint)
    NVG.Fill(vg)

    # End
    NVG.BeginPath(vg)
    NVG.Circle(vg, @zc.base_x+@zc.width,@zc.base_y+@zc.width, 10.0)
    paint = NVG.RadialGradient(vg, @zc.base_x+@zc.width,@zc.base_y+@zc.width, 0.1,10, NVG.RGBA(255,0,0,192), NVG.RGBA(255,0,0,0))
    NVG.FillPaint(vg, paint)
    NVG.Fill(vg)

    NVG.Restore(vg)
  end

end

################################################################################

class Showcase

  def set_viewport_size(w, h)
    @width = w
    @height = h
  end

  def initialize()
    @width = 0
    @height = 0
    @scene_id = 0
    @scenes = [
      ZOrderCurveScene.new("ZOrder Curve Scene"),
      HilbertCurveScene.new("Hilbert Curve Scene"),
      DragonCurveScene.new("Dragon Curve Scene"),
      TriangleScene.new("Triangle Scene"),
      ArrowScene.new("Arrow Scene"),
      GridScene.new("Grid Scene"),
    ]
  end

  def current_scene
    @scenes[@scene_id]
  end

  def scene_name()
    @scenes[@scene_id].name
  end

  def render(vg, dt)
    @scenes[@scene_id].render(vg, @width, @height, dt)
  end

  def next_scene
    @scene_id += 1
    @scene_id = @scene_id % @scenes.length
  end

  def prev_scene
    @scene_id -= 1
    @scene_id = (@scene_id + @scenes.length) % @scenes.length
  end

end
