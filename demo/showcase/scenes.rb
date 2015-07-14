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
      GridScene.new("Grid Scene"),
    ]
  end

  def render(vg, dt)
    @scenes[@scene_id].render(vg, @width, @height, dt)
  end

  def set_next_scene
    @scene_id += 1
    @scene_id = @scene_id % @scenes.length
  end

  def set_prev_scene
    @scene_id -= 1
    @scene_id = (@scene_id + @scenes.length) % @scenes.length
  end

end
