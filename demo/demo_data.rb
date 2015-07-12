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

  def maxf(a, b)
    return a > b ? a : b
  end
  private :maxf

  def mini(a, b)
    return a < b ? a : b
  end

  def clampf(a, mn, mx)
    return a < mn ? mn : (a > mx ? mx : a)
  end
  private :clampf

  def isBlack(col)
    color = col[:rgba].to_a
    if color[0] == 0.0 && color[1] == 0.0 && color[2] == 0.0 && color[3] == 0.0
      return true
    else
      return false
    end
  end
  private :isBlack

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

  def drawSpinner(vg, cx, cy, r, t)
    a0 = 0.0 + t*6
    a1 = Math::PI + t*6
    r0 = r
    r1 = r * 0.75

    nvgSave(vg)

    nvgBeginPath(vg)
    nvgArc(vg, cx,cy, r0, a0, a1, NVG_CW)
    nvgArc(vg, cx,cy, r1, a1, a0, NVG_CCW)
    nvgClosePath(vg)
    ax = cx + Math.cos(a0) * (r0+r1)*0.5
    ay = cy + Math.sin(a0) * (r0+r1)*0.5
    bx = cx + Math.cos(a1) * (r0+r1)*0.5
    by = cy + Math.sin(a1) * (r0+r1)*0.5
    paint = nvgLinearGradient(vg, ax,ay, bx,by, nvgRGBA(0,0,0,0), nvgRGBA(0,0,0,128))
    nvgFillPaint(vg, paint)
    nvgFill(vg)

    nvgRestore(vg)
  end

  def drawThumbnails(vg, x, y, w, h, images, nimages, t)
    cornerRadius = 3.0
    thumb = 60.0
    arry = 30.5
    stackh = (nimages/2) * (thumb+10) + 10

    u = (1+Math.cos(t*0.5))*0.5
    u2 = (1-Math.cos(t*0.2))*0.5

    nvgSave(vg)

    #  Drop shadow
    shadowPaint = nvgBoxGradient(vg, x,y+4, w,h, cornerRadius*2, 20, nvgRGBA(0,0,0,128), nvgRGBA(0,0,0,0))
    nvgBeginPath(vg)
    nvgRect(vg, x-10,y-10, w+20,h+30)
    nvgRoundedRect(vg, x,y, w,h, cornerRadius)
    nvgPathWinding(vg, NVG_HOLE)
    nvgFillPaint(vg, shadowPaint)
    nvgFill(vg)

    #  Window
    nvgBeginPath(vg)
    nvgRoundedRect(vg, x,y, w,h, cornerRadius)
    nvgMoveTo(vg, x-10,y+arry)
    nvgLineTo(vg, x+1,y+arry-11)
    nvgLineTo(vg, x+1,y+arry+11)
    nvgFillColor(vg, nvgRGBA(200,200,200,255))
    nvgFill(vg)

    nvgSave(vg)
    nvgScissor(vg, x,y,w,h)
    nvgTranslate(vg, 0, -(stackh - h)*u)

    dv = 1.0 / (nimages-1).to_f

    imgw_buf = '    '
    imgh_buf = '    '
    nimages.times do |i|
      tx = x+10
      ty = y+10
      tx += (i%2) * (thumb+10)
      ty += (i/2) * (thumb+10)
      nvgImageSize(vg, images[i], imgw_buf, imgh_buf)
      imgw = imgw_buf.unpack('L')[0]
      imgh = imgh_buf.unpack('L')[0]
      if imgw < imgh
        iw = thumb
        ih = iw * imgh.to_f/imgw.to_f
        ix = 0
        iy = -(ih-thumb)*0.5
      else 
        ih = thumb
        iw = ih * imgw.to_f/imgh.to_f
        ix = -(iw-thumb)*0.5
        iy = 0
      end

      v = i * dv
      a = clampf((u2-v) / dv, 0, 1)

      if (a < 1.0)
        drawSpinner(vg, tx+thumb/2,ty+thumb/2, thumb*0.25, t)
      end
      imgPaint = nvgImagePattern(vg, tx+ix, ty+iy, iw,ih, 0.0/180.0*Math::PI, images[i], a)
      nvgBeginPath(vg)
      nvgRoundedRect(vg, tx,ty, thumb,thumb, 5)
      nvgFillPaint(vg, imgPaint)
      nvgFill(vg)

      shadowPaint = nvgBoxGradient(vg, tx-1,ty, thumb+2,thumb+2, 5, 3, nvgRGBA(0,0,0,128), nvgRGBA(0,0,0,0))
      nvgBeginPath(vg)
      nvgRect(vg, tx-5,ty-5, thumb+10,thumb+10)
      nvgRoundedRect(vg, tx,ty, thumb,thumb, 6)
      nvgPathWinding(vg, NVG_HOLE)
      nvgFillPaint(vg, shadowPaint)
      nvgFill(vg)

      nvgBeginPath(vg)
      nvgRoundedRect(vg, tx+0.5,ty+0.5, thumb-1,thumb-1, 4-0.5)
      nvgStrokeWidth(vg,1.0)
      nvgStrokeColor(vg, nvgRGBA(255,255,255,192))
      nvgStroke(vg)
    end
    nvgRestore(vg)

    #  Hide fades
    fadePaint = nvgLinearGradient(vg, x,y,x,y+6, nvgRGBA(200,200,200,255), nvgRGBA(200,200,200,0))
    nvgBeginPath(vg)
    nvgRect(vg, x+4,y,w-8,6)
    nvgFillPaint(vg, fadePaint)
    nvgFill(vg)

    fadePaint = nvgLinearGradient(vg, x,y+h,x,y+h-6, nvgRGBA(200,200,200,255), nvgRGBA(200,200,200,0))
    nvgBeginPath(vg)
    nvgRect(vg, x+4,y+h-6,w-8,6)
    nvgFillPaint(vg, fadePaint)
    nvgFill(vg)

    #  Scroll bar
    shadowPaint = nvgBoxGradient(vg, x+w-12+1,y+4+1, 8,h-8, 3,4, nvgRGBA(0,0,0,32), nvgRGBA(0,0,0,92))
    nvgBeginPath(vg)
    nvgRoundedRect(vg, x+w-12,y+4, 8,h-8, 3)
    nvgFillPaint(vg, shadowPaint)
    nvgFill(vg)

    scrollh = (h/stackh) * (h-8)
    shadowPaint = nvgBoxGradient(vg, x+w-12-1,y+4+(h-8-scrollh)*u-1, 8,scrollh, 3,4, nvgRGBA(220,220,220,255), nvgRGBA(128,128,128,255))
    nvgBeginPath(vg)
    nvgRoundedRect(vg, x+w-12+1,y+4+1 + (h-8-scrollh)*u, 8-2,scrollh-2, 2)
    nvgFillPaint(vg, shadowPaint)
    nvgFill(vg)

    nvgRestore(vg)
  end

  def drawColorwheel(vg, x, y, w, h, t)
    hue = Math.sin(t * 0.12)

    nvgSave(vg)

    cx = x + w*0.5
    cy = y + h*0.5
    r1 = (w < h ? w : h) * 0.5 - 5.0
    r0 = r1 - 20.0
    aeps = 0.5 / r1   #  half a pixel arc length in radians (2pi cancels out).

    6.times do |i|
      a0 = i.to_f / 6.0 * Math::PI * 2.0 - aeps
      a1 = (i+1.0).to_f / 6.0 * Math::PI * 2.0 + aeps
      nvgBeginPath(vg)
      nvgArc(vg, cx,cy, r0, a0, a1, NVG_CW)
      nvgArc(vg, cx,cy, r1, a1, a0, NVG_CCW)
      nvgClosePath(vg)
      ax = cx + Math.cos(a0) * (r0+r1)*0.5
      ay = cy + Math.sin(a0) * (r0+r1)*0.5
      bx = cx + Math.cos(a1) * (r0+r1)*0.5
      by = cy + Math.sin(a1) * (r0+r1)*0.5
      paint = nvgLinearGradient(vg, ax,ay, bx,by, nvgHSLA(a0/(Math::PI*2),1.0,0.55,255), nvgHSLA(a1/(Math::PI*2),1.0,0.55,255))
      nvgFillPaint(vg, paint)
      nvgFill(vg)
    end

    nvgBeginPath(vg)
    nvgCircle(vg, cx,cy, r0-0.5)
    nvgCircle(vg, cx,cy, r1+0.5)
    nvgStrokeColor(vg, nvgRGBA(0,0,0,64))
    nvgStrokeWidth(vg, 1.0)
    nvgStroke(vg)

    #  Selector
    nvgSave(vg)
    nvgTranslate(vg, cx,cy)
    nvgRotate(vg, hue*Math::PI*2)

    #  Marker on
    nvgStrokeWidth(vg, 2.0)
    nvgBeginPath(vg)
    nvgRect(vg, r0-1,-3,r1-r0+2,6)
    nvgStrokeColor(vg, nvgRGBA(255,255,255,192))
    nvgStroke(vg)

    paint = nvgBoxGradient(vg, r0-3,-5,r1-r0+6,10, 2,4, nvgRGBA(0,0,0,128), nvgRGBA(0,0,0,0))
    nvgBeginPath(vg)
    nvgRect(vg, r0-2-10,-4-10,r1-r0+4+20,8+20)
    nvgRect(vg, r0-2,-4,r1-r0+4,8)
    nvgPathWinding(vg, NVG_HOLE)
    nvgFillPaint(vg, paint)
    nvgFill(vg)

    #  Center triangle
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

    #  Select circle on triangle
    ax = Math.cos(120.0/180.0*Math::PI) * r*0.3
    ay = Math.sin(120.0/180.0*Math::PI) * r*0.4
    nvgStrokeWidth(vg, 2.0)
    nvgBeginPath(vg)
    nvgCircle(vg, ax,ay,5)
    nvgStrokeColor(vg, nvgRGBA(255,255,255,192))
    nvgStroke(vg)

    paint = nvgRadialGradient(vg, ax,ay, 7,9, nvgRGBA(0,0,0,64), nvgRGBA(0,0,0,0))
    nvgBeginPath(vg)
    nvgRect(vg, ax-20,ay-20,40,40)
    nvgCircle(vg, ax,ay,7)
    nvgPathWinding(vg, NVG_HOLE)
    nvgFillPaint(vg, paint)
    nvgFill(vg)

    nvgRestore(vg)

    nvgRestore(vg)
  end

  def drawLines(vg, x, y, w, h, t)
    pad = 5.0
    s = w/9.0 - pad*2
    pts = Array.new(4*2) { 0.0 }
    joins = [NVG_MITER, NVG_ROUND, NVG_BEVEL]
    caps = [NVG_BUTT, NVG_ROUND, NVG_SQUARE]

    nvgSave(vg)
    pts[0] = -s*0.25 + Math.cos(t*0.3) * s*0.5
    pts[1] = Math.sin(t*0.3) * s*0.5
    pts[2] = -s*0.25
    pts[3] = 0
    pts[4] = s*0.25
    pts[5] = 0
    pts[6] = s*0.25 + Math.cos(-t*0.3) * s*0.5
    pts[7] = Math.sin(-t*0.3) * s*0.5

    3.times do |i|
      3.times do |j|
        fx = x + s*0.5 + (i*3+j)/9.0*w + pad
        fy = y - s*0.5 + pad

        nvgLineCap(vg, caps[i])
        nvgLineJoin(vg, joins[j])

        nvgStrokeWidth(vg, s*0.3)
        nvgStrokeColor(vg, nvgRGBA(0,0,0,160))
        nvgBeginPath(vg)
        nvgMoveTo(vg, fx+pts[0], fy+pts[1])
        nvgLineTo(vg, fx+pts[2], fy+pts[3])
        nvgLineTo(vg, fx+pts[4], fy+pts[5])
        nvgLineTo(vg, fx+pts[6], fy+pts[7])
        nvgStroke(vg)

        nvgLineCap(vg, NVG_BUTT)
        nvgLineJoin(vg, NVG_BEVEL)

        nvgStrokeWidth(vg, 1.0)
        nvgStrokeColor(vg, nvgRGBA(0,192,255,255))
        nvgBeginPath(vg)
        nvgMoveTo(vg, fx+pts[0], fy+pts[1])
        nvgLineTo(vg, fx+pts[2], fy+pts[3])
        nvgLineTo(vg, fx+pts[4], fy+pts[5])
        nvgLineTo(vg, fx+pts[6], fy+pts[7])
        nvgStroke(vg)
      end
    end

    nvgRestore(vg)
  end

  def drawParagraph(vg, x, y, width, height, mx, my)
    rows_buf = FFI::MemoryPointer.new(NVGtextRow, 3) # Ref.: https://github.com/ffi/ffi/wiki/Structs
    glyphs_buf = FFI::MemoryPointer.new(NVGglyphPosition, 100)
    text = "This is longer chunk of text.\n  \n  Would have used lorem ipsum but she    was busy jumping over the lazy dog with the fox and all the men who came to the aid of the party."
    lnum = 0
    lineh_buf = '        '
    lineh = 0.0
    gx = 0.0
    gy = 0.0
    gutter = 0

    nvgSave(vg)

    nvgFontSize(vg, 18.0)
    nvgFontFace(vg, "sans")
    nvgTextAlign(vg, NVG_ALIGN_LEFT|NVG_ALIGN_TOP)
    nvgTextMetrics(vg, nil, nil, lineh_buf)
    lineh = lineh_buf.unpack('F')[0]

    #  The text break API can be used to fill a large buffer of rows,
    #  or to iterate over the text just few lines (or just one) at a time.
    #  The "next" variable of the last returned item tells where to continue.
    text_start = text
    text_end = nil # text + text.length
    while ((nrows = nvgTextBreakLines(vg, text_start, text_end, width, rows_buf, 3)))
      rows = nrows.times.collect do |i|
        NVGtextRow.new(rows_buf + i * NVGtextRow.size) # Ref.: https://github.com/ffi/ffi/wiki/Structs
      end
      nrows.times do |i|
        row = rows[i]
        hit = mx > x && mx < (x+width) && my >= y && my < (y+lineh)

        nvgBeginPath(vg)
        nvgFillColor(vg, nvgRGBA(255,255,255, (hit ? 64 : 16)))
        nvgRect(vg, x, y, row[:width], lineh)
        nvgFill(vg)

        nvgFillColor(vg, nvgRGBA(255,255,255,255))
        nvgText(vg, x, y, row[:start], row[:end])

        if hit
          caretx = (mx < x+row[:width]/2) ? x : x+row[:width]
          px = x
          nglyphs = nvgTextGlyphPositions(vg, x, y, row[:start], row[:end], glyphs_buf, 100)
          glyphs = nglyphs.times.collect do |i|
            NVGglyphPosition.new(glyphs_buf + i * NVGglyphPosition.size)
          end
          nglyphs.times do |j|
            x0 = glyphs[j][:x]
            x1 = (j+1 < nglyphs) ? glyphs[j+1][:x] : x+row[:width]
            gx = x0 * 0.3 + x1 * 0.7
            if mx >= px && mx < gx
              caretx = glyphs[j][:x]
            end
            px = gx
          end
          nvgBeginPath(vg)
          nvgFillColor(vg, nvgRGBA(255,192,0,255))
          nvgRect(vg, caretx, y, 1, lineh)
          nvgFill(vg)

          gutter = lnum+1
          gx = x - 10
          gy = y + lineh/2
        end
        lnum = lnum + 1
        y += lineh
      end
      #  Keep going...
      if rows.length > 0
        text_start = rows[nrows-1][:next]
      else
        break
      end
    end

    bounds_buf = '                                '
    if gutter
      txt = sprintf("%d", gutter)
      nvgFontSize(vg, 13.0)
      nvgTextAlign(vg, NVG_ALIGN_RIGHT|NVG_ALIGN_MIDDLE)

      nvgTextBounds(vg, gx, gy, txt, nil, bounds_buf)
      bounds = bounds_buf.unpack('F4')

      nvgBeginPath(vg)
      nvgFillColor(vg, nvgRGBA(255,192,0,255))
      nvgRoundedRect(vg, bounds[0].to_i-4,bounds[1].to_i-2, (bounds[2]-bounds[0]).to_i+8, (bounds[3]-bounds[1]).to_i+4, ((bounds[3]-bounds[1]).to_i+4)/2-1)
      nvgFill(vg)

      nvgFillColor(vg, nvgRGBA(32,32,32,255))
      nvgText(vg, gx,gy, txt, nil)
    end

    y += 20.0

    nvgFontSize(vg, 13.0)
    nvgTextAlign(vg, NVG_ALIGN_LEFT|NVG_ALIGN_TOP)
    nvgTextLineHeight(vg, 1.2)

    nvgTextBoxBounds(vg, x,y, 150, "Hover your mouse over the text to see calculated caret position.", nil, bounds_buf)
    bounds = bounds_buf.unpack('F4')

    #  Fade the tooltip out when close to it.
    gx = ((mx - (bounds[0]+bounds[2])*0.5) / (bounds[0] - bounds[2])).abs
    gy = ((my - (bounds[1]+bounds[3])*0.5) / (bounds[1] - bounds[3])).abs
    a = maxf(gx, gy) - 0.5
    a = clampf(a, 0, 1)
    nvgGlobalAlpha(vg, a)

    nvgBeginPath(vg)
    nvgFillColor(vg, nvgRGBA(220,220,220,255))
    nvgRoundedRect(vg, bounds[0]-2,bounds[1]-2, (bounds[2]-bounds[0]).to_i+4, (bounds[3]-bounds[1]).to_i+4, 3)
    px = ((bounds[2]+bounds[0])/2).to_i
    nvgMoveTo(vg, px,bounds[1] - 10)
    nvgLineTo(vg, px+7,bounds[1]+1)
    nvgLineTo(vg, px-7,bounds[1]+1)
    nvgFill(vg)

    nvgFillColor(vg, nvgRGBA(0,0,0,220))
    nvgTextBox(vg, x,y, 150, "Hover your mouse over the text to see calculated caret position.", nil)

    nvgRestore(vg)
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

  def drawScissor(vg, x, y, t)
    nvgSave(vg)

    #  Draw first rect and set scissor to it's area.
    nvgTranslate(vg, x, y)
    nvgRotate(vg, nvgDegToRad(5))
    nvgBeginPath(vg)
    nvgRect(vg, -20,-20,60,40)
    nvgFillColor(vg, nvgRGBA(255,0,0,255))
    nvgFill(vg)
    nvgScissor(vg, -20,-20,60,40)

    #  Draw second rectangle with offset and rotation.
    nvgTranslate(vg, 40,0)
    nvgRotate(vg, t)

    #  Draw the intended second rectangle without any scissoring.
    nvgSave(vg)
    nvgResetScissor(vg)
    nvgBeginPath(vg)
    nvgRect(vg, -20,-10,60,30)
    nvgFillColor(vg, nvgRGBA(255,128,0,64))
    nvgFill(vg)
    nvgRestore(vg)

    #  Draw second rectangle with combined scissoring.
    nvgIntersectScissor(vg, -20,-10,60,30)
    nvgBeginPath(vg)
    nvgRect(vg, -20,-10,60,30)
    nvgFillColor(vg, nvgRGBA(255,128,0,255))
    nvgFill(vg)

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
    drawParagraph(vg, width - 450, 50, 150, 100, mx, my)
    drawGraph(vg, 0, height/2, width, height/2, t)
    drawColorwheel(vg, width - 300, height - 300, 250.0, 250.0, t)

    drawLines(vg, 120, height-50, 600, 50, t)
    drawWidths(vg, 10, 50, 30)
    drawCaps(vg, 10, 300, 30)
    drawScissor(vg, 50, height-80, t)

    nvgSave(vg)
    if blowup
      nvgRotate(vg, Math.sin(t*0.3)*5.0/180.0*Math::PI)
      nvgScale(vg, 2.0, 2.0)
    end

    #  Widgets
    drawWindow(vg, "Widgets `n Stuff", 50, 50, 300, 400)
    x = 60
    y = 95
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

    #  Thumbnails box
    drawThumbnails(vg, 365, popy-30, 160, 300, @images, 12, t)

    nvgRestore(vg)
  end

  # Saves as .tga
  def save_screenshot(w, h, name)
    image = FFI::MemoryPointer.new(:uint8, w*h*4)
    return if image == nil

    glReadPixels(0, 0, w, h, GL_BGRA, GL_UNSIGNED_INT_8_8_8_8_REV, image)

    File.open( name, 'wb' ) do |fout|
      fout.write [0].pack('c')      # identsize
      fout.write [0].pack('c')      # colourmaptype
      fout.write [2].pack('c')      # imagetype
      fout.write [0].pack('s')      # colourmapstart
      fout.write [0].pack('s')      # colourmaplength
      fout.write [0].pack('c')      # colourmapbits
      fout.write [0].pack('s')      # xstart
      fout.write [0].pack('s')      # ystart
      fout.write [w].pack('s')      # image_width
      fout.write [h].pack('s')      # image_height
      fout.write [8 * 4].pack('c')  # image_bits_per_pixel
      fout.write [8].pack('c')      # descriptor

      fout.write image.get_bytes(0, w*h*4)
    end
  end
end
