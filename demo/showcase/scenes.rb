class Scene
  attr_reader :name
  def initialize(name); @name = name; end
  def init; end
  def term; end
  def render(vg, width, height, dt = 0.0); end
end

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
    nvgSave(vg)
    nx.times do |i|
      x = div * i
      nvgStrokeWidth(vg, lw)
      nvgStrokeColor(vg, nvgRGBA(255,255,255,255))
      nvgBeginPath(vg)
      nvgMoveTo(vg, x, 0.0)
      nvgLineTo(vg, x, height)
      nvgStroke(vg)
    end
    ny.times do |i|
      y = div * i
      nvgStrokeWidth(vg, lw)
      nvgStrokeColor(vg, nvgRGBA(255,255,255,255))
      nvgBeginPath(vg)
      nvgMoveTo(vg, 0, y)
      nvgLineTo(vg, width, y)
      nvgStroke(vg)
    end
    nvgRestore(vg)
  end

end

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

    nvgSave(vg)

    nvgStrokeWidth(vg, 2.0)
    nvgStrokeColor(vg, nvgRGBA(255,255,255,192))

    nvgTranslate(vg, x,y)
    nvgRotate(vg, hue*Math::PI*2)

    r1 = (width < height ? width : height) * 0.5 - 5.0
    r0 = r1 - 20.0
    r = r0 - 6
    ax = Math.cos(120.0/180.0*Math::PI) * r
    ay = Math.sin(120.0/180.0*Math::PI) * r
    bx = Math.cos(-120.0/180.0*Math::PI) * r
    by = Math.sin(-120.0/180.0*Math::PI) * r

    nvgBeginPath(vg)
    nvgMoveTo(vg, r,0)
    nvgLineTo(vg, ax,ay)
    nvgLineTo(vg, bx,by)
    nvgClosePath(vg)
    paint = nvgLinearGradient(vg, r,0, ax,ay, nvgHSLA(hue,1.0,0.5,255), nvgRGBA(255,255,255,255))
    nvgFillPaint(vg, paint)
    nvgFill(vg)
    paint = nvgLinearGradient(vg, (r+ax)*0.5,(0+ay)*0.5, bx,by, nvgRGBA(0,0,0,0), nvgRGBA(0,0,0,255))
    nvgFillPaint(vg, paint)
    nvgFill(vg)
    nvgStrokeColor(vg, nvgRGBA(0,0,0,64))
    nvgStroke(vg)

    nvgRestore(vg)
  end

end


module Arrow

  def self.render_simple(vg, src_x, src_y, dst_x, dst_y, outer_line: true, inner_fill: true,
                         color: nvgRGBA(255,255,255,255), gradient_start: color, gradient_end: color)
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

    nvgSave(vg)
    nvgTranslate(vg, src_x,src_y)
    nvgRotate(vg, theta)
    nvgScale(vg, scaling, scaling)

    nvgBeginPath(vg)
    nvgMoveTo(vg, end_base_x, end_base_y)
    nvgLineTo(vg, end_base_x, end_base_y + bw / 2)
    nvgLineTo(vg, end_base_x + bl, end_base_y + bw / 2)
    nvgLineTo(vg, end_base_x + bl, end_base_y + hw / 2)
    nvgLineTo(vg, end_base_x + l, end_base_y)
    nvgLineTo(vg, end_base_x + bl, end_base_y - hw / 2)
    nvgLineTo(vg, end_base_x + bl, end_base_y - bw / 2)
    nvgLineTo(vg, end_base_x, end_base_y - bw / 2)
    nvgClosePath(vg)

    # Outer Line
    if outer_line
      nvgStrokeWidth(vg, 5 / scaling)
      nvgStrokeColor(vg, color)
      nvgStroke(vg)
    end

    # Inner Area
    if inner_fill
      paint = nvgLinearGradient(vg, end_base_x,end_base_y, end_base_x+l,end_base_y, gradient_start, gradient_end)
      nvgFillPaint(vg, paint)
      nvgFill(vg)
    end

    nvgRestore(vg)
  end

  def self.render(vg, src_x, src_y, dst_x, dst_y, head_length: 100.0, head_width: head_length/3, shaft_width: head_width/2,
                  outer_line: true, inner_fill: true, outer_width: 2.5, outer_color: nvgRGBA(255,255,255,255), gradient_start: nvgRGBA(255,255,255,0), gradient_end: nvgRGBA(255,255,255,255))

    arrow_length = Math.sqrt((dst_x - src_x)**2 + (dst_y - src_y)**2)
    bottom_x = 0.0
    bottom_y = 0.0
    toptip_x = arrow_length
    toptip_y = 0.0
    shaft_length = arrow_length - head_length
    arrow_length_base = Math.sqrt((bottom_x - toptip_x)**2 + (bottom_y - toptip_y)**2)

    theta = Math.atan2( (dst_y - src_y)/arrow_length, (dst_x - src_x) / arrow_length )

    nvgSave(vg)
    nvgTranslate(vg, src_x,src_y)
    nvgRotate(vg, theta)

    nvgBeginPath(vg)
    nvgMoveTo(vg, bottom_x, bottom_y)
    nvgLineTo(vg, bottom_x, bottom_y + shaft_width / 2)
    nvgLineTo(vg, bottom_x + shaft_length, bottom_y + shaft_width / 2)
    nvgLineTo(vg, bottom_x + shaft_length, bottom_y + head_width / 2)
    nvgLineTo(vg, bottom_x + arrow_length, bottom_y)
    nvgLineTo(vg, bottom_x + shaft_length, bottom_y - head_width / 2)
    nvgLineTo(vg, bottom_x + shaft_length, bottom_y - shaft_width / 2)
    nvgLineTo(vg, bottom_x, bottom_y - shaft_width / 2)
    nvgClosePath(vg)

    # Outer Line
    if outer_line
      nvgStrokeWidth(vg, outer_width)
      nvgStrokeColor(vg, outer_color)
      nvgStroke(vg)
    end

    # Inner Area
    if inner_fill
      paint = nvgLinearGradient(vg, bottom_x,bottom_y, bottom_x+arrow_length,bottom_y, gradient_start, gradient_end)
      nvgFillPaint(vg, paint)
      nvgFill(vg)
    end

    nvgRestore(vg)
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

    nvgSave(vg)

    src_x = 100
    src_y = 500
    dst_x = 900
    dst_y = 100
  # Arrow.render_simple(vg, src_x, src_y, dst_x, dst_y)
    Arrow.render(vg, src_x, src_y, dst_x, dst_y)

    nvgBeginPath(vg)
    nvgCircle(vg, src_x,src_y, 10.0)
    paint = nvgRadialGradient(vg, src_x,src_y, 0.1,10, nvgRGBA(0,255,0,192), nvgRGBA(0,255,0,0))
    nvgFillPaint(vg, paint)
    nvgFill(vg)

    nvgBeginPath(vg)
    nvgCircle(vg, dst_x,dst_y, 10.0)
    paint = nvgRadialGradient(vg, dst_x,dst_y, 0.1,10, nvgRGBA(255,0,0,192), nvgRGBA(255,0,0,0))
    nvgFillPaint(vg, paint)
    nvgFill(vg)

    nvgRestore(vg)
  end

end

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
      TriangleScene.new("Triangle Scene"),
      ArrowScene.new("Arrow Scene"),
      GridScene.new("Grid Scene"),
    ]
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
