class DemoData
  attr_accessor :fontNormal, :fontBold, :fontIcons, :images
  def initialize
    @fontNormal = -1
    @fontBold = -1
    @fontIcons = -1
    @images = Array.new(12) { -1 }
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
  end

  def save_screenshot(w, h, premult, name)
  end
end
