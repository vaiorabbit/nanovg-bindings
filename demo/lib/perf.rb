class PerfGraph

  GRAPH_RENDER_FPS     = 0
  GRAPH_RENDER_MS      = 1
  GRAPH_RENDER_PERCENT = 2

  GRAPH_HISTORY_COUNT = 100

  def initialize(style, name)
    @style = style
    @name = name
    @values = Array.new(GRAPH_HISTORY_COUNT) { 0.0 }
    @head = 0
  end

  def update(frameTime)
    @head = (@head + 1) % GRAPH_HISTORY_COUNT
    @values[@head] = frameTime
  end

  def average
    return @values.inject(:+) / GRAPH_HISTORY_COUNT
  end

  def render(vg, x, y)
    avg = average()

    w = 200
    h = 35

    NVG.BeginPath(vg)
    NVG.Rect(vg, x,y, w,h)
    NVG.FillColor(vg, NVG.RGBA(0,0,0,128))
    NVG.Fill(vg)

    NVG.BeginPath(vg)
    NVG.MoveTo(vg, x, y+h)
    if @style == GRAPH_RENDER_FPS
      GRAPH_HISTORY_COUNT.times do |i|
        v = 1.0 / (0.00001 + @values[(@head+i) % GRAPH_HISTORY_COUNT])
        v = 80.0 if v > 80.0
        vx = x + (i.to_f/(GRAPH_HISTORY_COUNT-1)) * w
        vy = y + h - ((v / 80.0) * h)
        NVG.LineTo(vg, vx, vy)
      end
    elsif @style == GRAPH_RENDER_PERCENT
      GRAPH_HISTORY_COUNT.times do |i|
        v = @values[(@head+i) % GRAPH_HISTORY_COUNT] * 1.0
        v = 100.0 if v > 100.0
        vx = x + (i.to_f/(GRAPH_HISTORY_COUNT-1)) * w
        vy = y + h - ((v / 100.0) * h)
        NVG.LineTo(vg, vx, vy)
      end
    else
      GRAPH_HISTORY_COUNT.times do |i|
        v = @values[(@head+i) % GRAPH_HISTORY_COUNT] * 1000.0
        v = 20.0 if v > 20.0
        vx = x + (i.to_f/(GRAPH_HISTORY_COUNT-1)) * w
        vy = y + h - ((v / 20.0) * h)
        NVG.LineTo(vg, vx, vy)
      end
    end
    NVG.LineTo(vg, x+w, y+h)
    NVG.FillColor(vg, NVG.RGBA(255,192,0,128))
    NVG.Fill(vg)

    NVG.FontFace(vg, "sans");

    if @name != ""
      NVG.FontSize(vg, 14.0)
      NVG.TextAlign(vg, NVG::ALIGN_LEFT|NVG::ALIGN_TOP)
      NVG.FillColor(vg, NVG.RGBA(240,240,240,192))
      NVG.Text(vg, x+3,y+1, @name, nil)
    end

    if @style == GRAPH_RENDER_FPS
      NVG.FontSize(vg, 18.0)
      NVG.TextAlign(vg, NVG::ALIGN_RIGHT|NVG::ALIGN_TOP)
      NVG.FillColor(vg, NVG.RGBA(240,240,240,255))
      str = sprintf("%.2f FPS", 1.0 / avg)
      NVG.Text(vg, x+w-3,y+1, str, nil)

      NVG.FontSize(vg, 15.0)
      NVG.TextAlign(vg, NVG::ALIGN_RIGHT|NVG::ALIGN_BOTTOM)
      NVG.FillColor(vg, NVG.RGBA(240,240,240,160))
      str = sprintf("%.2f ms", avg * 1000.0)
      NVG.Text(vg, x+w-3,y+h-1, str, nil)
    elsif (@style == GRAPH_RENDER_PERCENT)
        NVG.FontSize(vg, 18.0)
        NVG.TextAlign(vg, NVG::ALIGN_RIGHT|NVG::ALIGN_TOP)
        NVG.FillColor(vg, NVG.RGBA(240,240,240,255))
        str = sprintf("%.1f %%", avg * 1.0)
        NVG.Text(vg, x+w-3,y+1, str, nil)
    else
        NVG.FontSize(vg, 18.0)
        NVG.TextAlign(vg, NVG::ALIGN_RIGHT|NVG::ALIGN_TOP)
        NVG.FillColor(vg, NVG.RGBA(240,240,240,255))
        str = sprintf("%.2f ms", avg * 1000.0)
        NVG.Text(vg, x+w-3,y+1, str, nil)
    end
  end
end
