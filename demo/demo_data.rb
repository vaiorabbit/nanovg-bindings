class DemoData

  attr_accessor :fontNormal, :fontBold, :fontIcons, :images
  def initialize
    @fontNormal = -1
    @fontBold = -1
    @fontIcons = -1
    @images = Array.new(12) { -1 }
  end

  ICON_SEARCH = 0x1F50D
  ICON_CIRCLED_CROSS = 0x2716
  ICON_CHEVRON_RIGHT = 0xE75E
  ICON_CHECK = 0x2713
  ICON_LOGIN = 0xE740
  ICON_TRASH = 0xE729

  def isBlack(col)
    color = col[:rgba].to_a
    if color[0] == 0.0 && color[1] == 0.0 && color[2] == 0.0 && color[3] == 0.0
      return true
    else
      return false
    end
  end

  def drawWindow(vg, title, x, y, w, h)
    cornerRadius = 3.0

    nvgSave(vg)

    #  Window
    nvgBeginPath(vg)
    nvgRoundedRect(vg, x,y, w,h, cornerRadius)
    nvgFillColor(vg, nvgRGBA(28,30,34,192))
    nvgFill(vg)

    #  Drop shadow
    shadowPaint = nvgBoxGradient(vg, x,y+2, w,h, cornerRadius*2, 10, nvgRGBA(0,0,0,128), nvgRGBA(0,0,0,0))
    nvgBeginPath(vg)
    nvgRect(vg, x-10,y-10, w+20,h+30)
    nvgRoundedRect(vg, x,y, w,h, cornerRadius)
    nvgPathWinding(vg, NVG_HOLE)
    nvgFillPaint(vg, shadowPaint)
    nvgFill(vg)

    #  Header
    headerPaint = nvgLinearGradient(vg, x,y,x,y+15, nvgRGBA(255,255,255,8), nvgRGBA(0,0,0,16))
    nvgBeginPath(vg)
    nvgRoundedRect(vg, x+1,y+1, w-2,30, cornerRadius-1)
    nvgFillPaint(vg, headerPaint)
    nvgFill(vg)
    nvgBeginPath(vg)
    nvgMoveTo(vg, x+0.5, y+0.5+30)
    nvgLineTo(vg, x+0.5+w-1, y+0.5+30)
    nvgStrokeColor(vg, nvgRGBA(0,0,0,32))
    nvgStroke(vg)

    nvgFontSize(vg, 18.0)
    nvgFontFace(vg, "sans-bold")
    nvgTextAlign(vg,NVG_ALIGN_CENTER|NVG_ALIGN_MIDDLE)

    nvgFontBlur(vg,2)
    nvgFillColor(vg, nvgRGBA(0,0,0,128))
    nvgText(vg, x+w/2,y+16+1, title, nil)

    nvgFontBlur(vg,0)
    nvgFillColor(vg, nvgRGBA(220,220,220,160))
    nvgText(vg, x+w/2,y+16, title, nil)

    nvgRestore(vg)
  end

  def drawSearchBox(vg, text, x, y, w, h)
    cornerRadius = h/2-1

    # Edit
    bg = nvgBoxGradient(vg, x,y+1.5, w,h, h/2,5, nvgRGBA(0,0,0,16), nvgRGBA(0,0,0,92))
    nvgBeginPath(vg)
    nvgRoundedRect(vg, x,y, w,h, cornerRadius)
    nvgFillPaint(vg, bg)
    nvgFill(vg)

    nvgFontSize(vg, h*1.3)
    nvgFontFace(vg, "icons")
    nvgFillColor(vg, nvgRGBA(255,255,255,64))
    nvgTextAlign(vg,NVG_ALIGN_CENTER|NVG_ALIGN_MIDDLE)
    nvgText(vg, x+h*0.55, y+h*0.55, [ICON_SEARCH].pack("U*"), nil)

    nvgFontSize(vg, 20.0)
    nvgFontFace(vg, "sans")
    nvgFillColor(vg, nvgRGBA(255,255,255,32))

    nvgTextAlign(vg,NVG_ALIGN_LEFT|NVG_ALIGN_MIDDLE)
    nvgText(vg, x+h*1.05,y+h*0.5,text, nil)

    nvgFontSize(vg, h*1.3)
    nvgFontFace(vg, "icons")
    nvgFillColor(vg, nvgRGBA(255,255,255,32))
    nvgTextAlign(vg,NVG_ALIGN_CENTER|NVG_ALIGN_MIDDLE)
    nvgText(vg, x+w-h*0.55, y+h*0.55, [ICON_CIRCLED_CROSS].pack("U*"), nil)
  end

  def drawDropDown(vg, text, x, y, w, h)
    cornerRadius = 4.0

    bg = nvgLinearGradient(vg, x,y,x,y+h, nvgRGBA(255,255,255,16), nvgRGBA(0,0,0,16))
    nvgBeginPath(vg)
    nvgRoundedRect(vg, x+1,y+1, w-2,h-2, cornerRadius-1)
    nvgFillPaint(vg, bg)
    nvgFill(vg)

    nvgBeginPath(vg)
    nvgRoundedRect(vg, x+0.5,y+0.5, w-1,h-1, cornerRadius-0.5)
    nvgStrokeColor(vg, nvgRGBA(0,0,0,48))
    nvgStroke(vg)

    nvgFontSize(vg, 20.0)
    nvgFontFace(vg, "sans")
    nvgFillColor(vg, nvgRGBA(255,255,255,160))
    nvgTextAlign(vg,NVG_ALIGN_LEFT|NVG_ALIGN_MIDDLE)
    nvgText(vg, x+h*0.3,y+h*0.5,text, nil)

    nvgFontSize(vg, h*1.3)
    nvgFontFace(vg, "icons")
    nvgFillColor(vg, nvgRGBA(255,255,255,64))
    nvgTextAlign(vg,NVG_ALIGN_CENTER|NVG_ALIGN_MIDDLE)
    nvgText(vg, x+w-h*0.5, y+h*0.5, [ICON_CHEVRON_RIGHT].pack("U*"), nil)
  end

  def drawLabel(vg, text, x, y, w, h)
    nvgFontSize(vg, 18.0)
    nvgFontFace(vg, "sans")
    nvgFillColor(vg, nvgRGBA(255,255,255,128))

    nvgTextAlign(vg,NVG_ALIGN_LEFT|NVG_ALIGN_MIDDLE)
    nvgText(vg, x,y+h*0.5,text, nil)
  end

  def drawEditBoxBase(vg, x, y, w, h)
    bg = nvgBoxGradient(vg, x+1,y+1+1.5, w-2,h-2, 3,4, nvgRGBA(255,255,255,32), nvgRGBA(32,32,32,32))
    nvgBeginPath(vg)
    nvgRoundedRect(vg, x+1,y+1, w-2,h-2, 4-1)
    nvgFillPaint(vg, bg)
    nvgFill(vg)

    nvgBeginPath(vg)
    nvgRoundedRect(vg, x+0.5,y+0.5, w-1,h-1, 4-0.5)
    nvgStrokeColor(vg, nvgRGBA(0,0,0,48))
    nvgStroke(vg)
  end

  def drawEditBox(vg, text, x, y, w, h)
    drawEditBoxBase(vg, x,y, w,h)

    nvgFontSize(vg, 20.0)
    nvgFontFace(vg, "sans")
    nvgFillColor(vg, nvgRGBA(255,255,255,64))
    nvgTextAlign(vg,NVG_ALIGN_LEFT|NVG_ALIGN_MIDDLE)
    nvgText(vg, x+h*0.3,y+h*0.5,text, nil)
  end

  def drawEditBoxNum(vg, text, units, x, y, w, h)
    drawEditBoxBase(vg, x,y, w,h)

    uw = nvgTextBounds(vg, 0,0, units, nil, nil)

    nvgFontSize(vg, 18.0)
    nvgFontFace(vg, "sans")
    nvgFillColor(vg, nvgRGBA(255,255,255,64))
    nvgTextAlign(vg,NVG_ALIGN_RIGHT|NVG_ALIGN_MIDDLE)
    nvgText(vg, x+w-h*0.3,y+h*0.5,units, nil)

    nvgFontSize(vg, 20.0)
    nvgFontFace(vg, "sans")
    nvgFillColor(vg, nvgRGBA(255,255,255,128))
    nvgTextAlign(vg,NVG_ALIGN_RIGHT|NVG_ALIGN_MIDDLE)
    nvgText(vg, x+w-uw-h*0.5,y+h*0.5,text, nil)
  end

  def drawCheckBox(vg, text, x, y, w, h)
    nvgFontSize(vg, 18.0)
    nvgFontFace(vg, "sans")
    nvgFillColor(vg, nvgRGBA(255,255,255,160))

    nvgTextAlign(vg,NVG_ALIGN_LEFT|NVG_ALIGN_MIDDLE)
    nvgText(vg, x+28,y+h*0.5,text, nil)

    bg = nvgBoxGradient(vg, x+1,y+(h*0.5).to_i-9+1, 18,18, 3,3, nvgRGBA(0,0,0,32), nvgRGBA(0,0,0,92))
    nvgBeginPath(vg)
    nvgRoundedRect(vg, x+1,y+(h*0.5).to_i-9, 18,18, 3)
    nvgFillPaint(vg, bg)
    nvgFill(vg)

    nvgFontSize(vg, 40)
    nvgFontFace(vg, "icons")
    nvgFillColor(vg, nvgRGBA(255,255,255,128))
    nvgTextAlign(vg,NVG_ALIGN_CENTER|NVG_ALIGN_MIDDLE)
    nvgText(vg, x+9+2, y+h*0.5, [ICON_CHECK].pack("U*"), nil)
  end

  def drawButton(vg, preicon, text, x, y, w, h, col)
    cornerRadius = 4.0
    tw = 0
    iw = 0

    bg = nvgLinearGradient(vg, x,y,x,y+h, nvgRGBA(255,255,255,isBlack(col)?16:32), nvgRGBA(0,0,0,isBlack(col)?16:32))
    nvgBeginPath(vg)
    nvgRoundedRect(vg, x+1,y+1, w-2,h-2, cornerRadius-1)
    if isBlack(col) == false
      nvgFillColor(vg, col)
      nvgFill(vg)
    end
    nvgFillPaint(vg, bg)
    nvgFill(vg)

    nvgBeginPath(vg)
    nvgRoundedRect(vg, x+0.5,y+0.5, w-1,h-1, cornerRadius-0.5)
    nvgStrokeColor(vg, nvgRGBA(0,0,0,48))
    nvgStroke(vg)

    nvgFontSize(vg, 20.0)
    nvgFontFace(vg, "sans-bold")
    tw = nvgTextBounds(vg, 0,0, text, nil, nil)
    if preicon != 0
      nvgFontSize(vg, h*1.3)
      nvgFontFace(vg, "icons")
      iw = nvgTextBounds(vg, 0,0, [preicon].pack("U*"), nil, nil)
      iw += h*0.15
    end

    if (preicon != 0) 
      nvgFontSize(vg, h*1.3)
      nvgFontFace(vg, "icons")
      nvgFillColor(vg, nvgRGBA(255,255,255,96))
      nvgTextAlign(vg,NVG_ALIGN_LEFT|NVG_ALIGN_MIDDLE)
      nvgText(vg, x+w*0.5-tw*0.5-iw*0.75, y+h*0.5, [preicon].pack("U*"), nil)
    end

    nvgFontSize(vg, 20.0)
    nvgFontFace(vg, "sans-bold")
    nvgTextAlign(vg,NVG_ALIGN_LEFT|NVG_ALIGN_MIDDLE)
    nvgFillColor(vg, nvgRGBA(0,0,0,160))
    nvgText(vg, x+w*0.5-tw*0.5+iw*0.25,y+h*0.5-1,text, nil)
    nvgFillColor(vg, nvgRGBA(255,255,255,160))
    nvgText(vg, x+w*0.5-tw*0.5+iw*0.25,y+h*0.5,text, nil)
  end

  def drawSlider(vg, pos, x, y, w, h)
    cy = y+(h*0.5).to_i
    kr = (h*0.25).to_i

    nvgSave(vg)

    #  Slot
    bg = nvgBoxGradient(vg, x,cy-2+1, w,4, 2,2, nvgRGBA(0,0,0,32), nvgRGBA(0,0,0,128))
    nvgBeginPath(vg)
    nvgRoundedRect(vg, x,cy-2, w,4, 2)
    nvgFillPaint(vg, bg)
    nvgFill(vg)

    #  Knob Shadow
    bg = nvgRadialGradient(vg, x+(pos*w).to_i,cy+1, kr-3,kr+3, nvgRGBA(0,0,0,64), nvgRGBA(0,0,0,0))
    nvgBeginPath(vg)
    nvgRect(vg, x+(pos*w).to_i-kr-5,cy-kr-5,kr*2+5+5,kr*2+5+5+3)
    nvgCircle(vg, x+(pos*w).to_i,cy, kr)
    nvgPathWinding(vg, NVG_HOLE)
    nvgFillPaint(vg, bg)
    nvgFill(vg)

    #  Knob
    knob = nvgLinearGradient(vg, x,cy-kr,x,cy+kr, nvgRGBA(255,255,255,16), nvgRGBA(0,0,0,16))
    nvgBeginPath(vg)
    nvgCircle(vg, x+(pos*w).to_i,cy, kr-1)
    nvgFillColor(vg, nvgRGBA(40,43,48,255))
    nvgFill(vg)
    nvgFillPaint(vg, knob)
    nvgFill(vg)

    nvgBeginPath(vg)
    nvgCircle(vg, x+(pos*w).to_i,cy, kr-0.5)
    nvgStrokeColor(vg, nvgRGBA(0,0,0,92))
    nvgStroke(vg)

    nvgRestore(vg)
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

  def drawGraph(vg, x, y, w, h, t)
    samples = Array.new(6) { 0.0 }
    sx = Array.new(6) { 0.0 }
    sy = Array.new(6) { 0.0 }
    dx = w/5.0

    samples[0] = (1+Math.sin(t*1.2345+Math.cos(t*0.33457)*0.44))*0.5
    samples[1] = (1+Math.sin(t*0.68363+Math.cos(t*1.3)*1.55))*0.5
    samples[2] = (1+Math.sin(t*1.1642+Math.cos(t*0.33457)*1.24))*0.5
    samples[3] = (1+Math.sin(t*0.56345+Math.cos(t*1.63)*0.14))*0.5
    samples[4] = (1+Math.sin(t*1.6245+Math.cos(t*0.254)*0.3))*0.5
    samples[5] = (1+Math.sin(t*0.345+Math.cos(t*0.03)*0.6))*0.5

    6.times do |i| 
      sx[i] = x+i*dx
      sy[i] = y+h*samples[i]*0.8
    end

    #  Graph background
    bg = nvgLinearGradient(vg, x,y,x,y+h, nvgRGBA(0,160,192,0), nvgRGBA(0,160,192,64))
    nvgBeginPath(vg)
    nvgMoveTo(vg, sx[0], sy[0])
    (1...6).each do |i|
      nvgBezierTo(vg, sx[i-1]+dx*0.5,sy[i-1], sx[i]-dx*0.5,sy[i], sx[i],sy[i])
    end
    nvgLineTo(vg, x+w, y+h)
    nvgLineTo(vg, x, y+h)
    nvgFillPaint(vg, bg)
    nvgFill(vg)

    #  Graph line
    nvgBeginPath(vg)
    nvgMoveTo(vg, sx[0], sy[0]+2)
    (1...6).each do |i|
      nvgBezierTo(vg, sx[i-1]+dx*0.5,sy[i-1]+2, sx[i]-dx*0.5,sy[i]+2, sx[i],sy[i]+2)
    end
    nvgStrokeColor(vg, nvgRGBA(0,0,0,32))
    nvgStrokeWidth(vg, 3.0)
    nvgStroke(vg)

    nvgBeginPath(vg)
    nvgMoveTo(vg, sx[0], sy[0])
    (1...6).each do |i|
      nvgBezierTo(vg, sx[i-1]+dx*0.5,sy[i-1], sx[i]-dx*0.5,sy[i], sx[i],sy[i])
    end
    nvgStrokeColor(vg, nvgRGBA(0,160,192,255))
    nvgStrokeWidth(vg, 3.0)
    nvgStroke(vg)

    #  Graph sample pos
    6.times do |i|
      bg = nvgRadialGradient(vg, sx[i],sy[i]+2, 3.0,8.0, nvgRGBA(0,0,0,32), nvgRGBA(0,0,0,0))
      nvgBeginPath(vg)
      nvgRect(vg, sx[i]-10, sy[i]-10+2, 20,20)
      nvgFillPaint(vg, bg)
      nvgFill(vg)
    end

    nvgBeginPath(vg)
    6.times do |i|
      nvgCircle(vg, sx[i], sy[i], 4.0)
    end
    nvgFillColor(vg, nvgRGBA(0,160,192,255))
    nvgFill(vg)
    nvgBeginPath(vg)
    6.times do |i|
      nvgCircle(vg, sx[i], sy[i], 2.0)
    end
    nvgFillColor(vg, nvgRGBA(220,220,220,255))
    nvgFill(vg)

    nvgStrokeWidth(vg, 1.0)
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

  def drawCaps(vg, x, y, width)
    caps = [NVG_BUTT, NVG_ROUND, NVG_SQUARE]
    lineWidth = 8.0

    nvgSave(vg)

    nvgBeginPath(vg)
    nvgRect(vg, x-lineWidth/2, y, width+lineWidth, 40)
    nvgFillColor(vg, nvgRGBA(255,255,255,32))
    nvgFill(vg)

    nvgBeginPath(vg)
    nvgRect(vg, x, y, width, 40)
    nvgFillColor(vg, nvgRGBA(255,255,255,32))
    nvgFill(vg)

    nvgStrokeWidth(vg, lineWidth)
    3.times do |i|
      nvgLineCap(vg, caps[i])
      nvgStrokeColor(vg, nvgRGBA(0,0,0,255))
      nvgBeginPath(vg)
      nvgMoveTo(vg, x, y + i*10 + 5)
      nvgLineTo(vg, x+width, y + i*10 + 5)
      nvgStroke(vg)
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

    @fontBold = nvgCreateFont(vg, "sans-bold", "./data/Roboto-Bold.ttf")
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
    drawGraph(vg, 0, height/2, width, height/2, t);

    drawWidths(vg, 10, 50, 30)
    drawCaps(vg, 10, 300, 30)

    #  Widgets
    drawWindow(vg, "Widgets `n Stuff", 50, 50, 300, 400)
    x = 60; y = 95;
    drawSearchBox(vg, "Search", x,y,280,25)
    y += 40
    drawDropDown(vg, "Effects", x,y,280,28)
    popy = y + 14
    y += 45

    #  Form
    drawLabel(vg, "Login", x,y, 280,20)
    y += 25
    drawEditBox(vg, "Email",  x,y, 280,28)
    y += 35
    drawEditBox(vg, "Password", x,y, 280,28)
    y += 38
    drawCheckBox(vg, "Remember me", x,y, 140,28)
    drawButton(vg, ICON_LOGIN, "Sign in", x+138, y, 140, 28, nvgRGBA(0,96,128,255))
    y += 45

    #  Slider
    drawLabel(vg, "Diameter", x,y, 280,20)
    y += 25
    drawEditBoxNum(vg, "123.00", "px", x+180,y, 100,28)
    drawSlider(vg, 0.4, x,y, 170,28)
    y += 55

    drawButton(vg, ICON_TRASH, "Delete", x, y, 160, 28, nvgRGBA(128,16,8,255))
    drawButton(vg, 0, "Cancel", x+170, y, 110, 28, nvgRGBA(0,0,0,0))
  end

  def save_screenshot(w, h, premult, name)
  end
end
