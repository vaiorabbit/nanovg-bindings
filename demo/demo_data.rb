class DemoData
  attr_accessor :fontNormal, :fontBold, :fontIcons, :images
  def initialize
    @fontNormal = -1
    @fontBold = -1
    @fontIcons = -1
    @images = Array.new(12) { -1 }
  end

  def drawEyes(vg, x, y, w, h, mx, my, t)
    gloss = NVGpaint.new
    bg = NVGpaint.new
    ex = w * 0.23
    ey = h * 0.5
    lx = x + ex
    ly = y + ey
    rx = x + w - ex
    ry = y + ey
    br = (ex < ey ? ex : ey) * 0.5
    blink = 1 - (Math.sin(t*0.5) ** 200)*0.8

    bg = nvgLinearGradient(vg, x,y+h*0.5,x+w*0.1,y+h, nvgRGBA(0,0,0,32), nvgRGBA(0,0,0,16))
    nvgBeginPath(vg)
    nvgEllipse(vg, lx+3.0,ly+16.0, ex,ey)
    nvgEllipse(vg, rx+3.0,ry+16.0, ex,ey)
    nvgFillPaint(vg, bg)
    nvgFill(vg)

    bg = nvgLinearGradient(vg, x,y+h*0.25,x+w*0.1,y+h, nvgRGBA(220,220,220,255), nvgRGBA(128,128,128,255))
    nvgBeginPath(vg)
    nvgEllipse(vg, lx,ly, ex,ey)
    nvgEllipse(vg, rx,ry, ex,ey)
    nvgFillPaint(vg, bg)
    nvgFill(vg)

    dx = (mx - rx) / (ex * 10)
    dy = (my - ry) / (ey * 10)
    d = Math.sqrt(dx*dx+dy*dy)
    if d > 1.0
      dx /= d
      dy /= d
    end
    dx *= ex*0.4
    dy *= ey*0.5
    nvgBeginPath(vg)
    nvgEllipse(vg, lx+dx,ly+dy+ey*0.25*(1-blink), br,br*blink)
    nvgFillColor(vg, nvgRGBA(32,32,32,255))
    nvgFill(vg)

    dx = (mx - rx) / (ex * 10)
    dy = (my - ry) / (ey * 10)
    d = Math.sqrt(dx*dx+dy*dy)
    if d > 1.0
      dx /= d
      dy /= d
    end
    dx *= ex*0.4
    dy *= ey*0.5
    nvgBeginPath(vg)
    nvgEllipse(vg, rx+dx,ry+dy+ey*0.25*(1-blink), br,br*blink)
    nvgFillColor(vg, nvgRGBA(32,32,32,255))
    nvgFill(vg)

    gloss = nvgRadialGradient(vg, lx-ex*0.25,ly-ey*0.5, ex*0.1,ex*0.75, nvgRGBA(255,255,255,128), nvgRGBA(255,255,255,0))
    nvgBeginPath(vg)
    nvgEllipse(vg, lx,ly, ex,ey)
    nvgFillPaint(vg, gloss)
    nvgFill(vg)

    gloss = nvgRadialGradient(vg, rx-ex*0.25,ry-ey*0.5, ex*0.1,ex*0.75, nvgRGBA(255,255,255,128), nvgRGBA(255,255,255,0))
    nvgBeginPath(vg)
    nvgEllipse(vg, rx,ry, ex,ey)
    nvgFillPaint(vg, gloss)
    nvgFill(vg)
  end

  def drawWidths(vg, x, y, width)
    nvgSave(vg)

    nvgStrokeColor(vg, nvgRGBA(0,0,0,255))

    20.times do |i|
      w = (i+0.5)*0.1
      nvgStrokeWidth(vg, w)
      nvgBeginPath(vg)
      nvgMoveTo(vg, x,y)
      nvgLineTo(vg, x+width,y+width*0.3)
      nvgStroke(vg)
      y += 10
    end

    nvgRestore(vg)
  end

  def load(vg)
    return -1 if vg == nil

    12.times do |i|
      file = sprintf("./data/image%d.jpg", i+1)
      @images[i] = nvgCreateImage(vg, file, 0)
      if @images[i] == 0
        puts("Could not load %s.", file)
        return -1
      end
    end

    @fontIcons = nvgCreateFont(vg, "icons", "./data/entypo.ttf")
    if @fontIcons == -1
      puts "Could not add font icons."
      return -1
    end

    @fontNormal = nvgCreateFont(vg, "sans", "./data/Roboto-Regular.ttf")
    if @fontNormal == -1
      puts "Could not add font italic."
      return -1
    end

    @fontBold = nvgCreateFont(vg, "icons", "./data/Roboto-Bold.ttf")
    if @fontBold == -1
      puts "Could not add font bold."
      return -1
    end

    return 0
  end

  def free(vg)
    return -1 if vg == nil
    12.times {|i| nvgDeleteImage(vg, @images[i]) }
  end

  def render(vg, mx, my, width, height, t, blowup)
    drawEyes(vg, width - 250, 50, 150, 100, mx, my, t)

    drawWidths(vg, 10, 50, 30)
  end

  def save_screenshot(w, h, premult, name)
  end
end
