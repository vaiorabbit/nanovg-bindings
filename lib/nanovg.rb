require 'ffi'

module NVG
  extend FFI::Library

  #
  # define/enum
  #

  # NVGwinding
  CCW = 1
  CW  = 2

  # NVGsolidity
  SOLID = 1
  HOLE  = 2

  # NVGlineCap
  BUTT   = 0
  ROUND  = 1
  SQUARE = 2
  BEVEL  = 3
  MITER  = 4

  # NVGalign
  #  Horizontal align
  ALIGN_LEFT     = 1
  ALIGN_CENTER   = 2
  ALIGN_RIGHT    = 4
  #  Vertical align
  ALIGN_TOP      = 8
  ALIGN_MIDDLE   = 16
  ALIGN_BOTTOM   = 32
  ALIGN_BASELINE = 64

  # NVGblendFactor
  ZERO                = 1 << 0
  ONE                 = 1 << 1
  SRC_COLOR           = 1 << 2
  ONE_MINUS_SRC_COLOR = 1 << 3
  DST_COLOR           = 1 << 4
  ONE_MINUS_DST_COLOR = 1 << 5
  SRC_ALPHA           = 1 << 6
  ONE_MINUS_SRC_ALPHA = 1 << 7
  DST_ALPHA           = 1 << 8
  ONE_MINUS_DST_ALPHA = 1 << 9
  SRC_ALPHA_SATURATE  = 1 << 10

  # NVGcompositeOperation
  SOURCE_OVER      = 0
  SOURCE_IN        = 1
  SOURCE_OUT       = 2
  ATOP             = 3
  DESTINATION_OVER = 4
  DESTINATION_IN   = 5
  DESTINATION_OUT  = 6
  DESTINATION_ATOP = 7
  LIGHTER          = 8
  COPY             = 9
  XOR              = 10

  # NVGimageFlags
  IMAGE_GENERATE_MIPMAPS  = 1
  IMAGE_REPEATX           = 2
  IMAGE_REPEATY           = 4
  IMAGE_FLIPY             = 8
  IMAGE_PREMULTIPLIED     = 16
  IMAGE_NEAREST           = 32

  # NVGcreateFlags
  ANTIALIAS         = 1
  STENCIL_STROKES   = 2
  DEBUG             = 4

  #
  # struct
  #

  class Color < FFI::Struct
    layout(
      :rgba, [:float, 4]
    )
  end

  class Paint < FFI::Struct
    layout(
      :xform,       [:float, 6],
      :extent,      [:float, 2],
      :radius,      :float,
      :feather,     :float,
      :innerColor,  Color,
      :outerColor,  Color,
      :image,       :int32
    )
  end

  class CompositeOperationState < FFI::Struct
    layout(
      :srcRGB,   :int32,
      :dstRGB,   :int32,
      :srcAlpha, :int32,
      :dstAlpha, :int32
    )
  end

  class GlyphPosition < FFI::Struct
    layout(
      :str,  :pointer,
      :x,    :float,
      :minx, :float,
      :maxx, :float
    )
  end

  class TextRow < FFI::Struct
    layout(
      :start, :pointer,
      :end,   :pointer,
      :next,  :pointer,
      :width, :float,
      :minx,  :float,
      :maxx,  :float
    )
  end

  #
  # Load native library.
  #
  @@nanovg_import_done = false

  def self.load_lib(libpath = './libnanovg.dylib', render_backend: :gl2)
    ffi_lib_flags :now, :global # to force FFI to access nvgCreateInternal from nvgCreateGL2
    ffi_lib libpath
    import_symbols(render_backend) unless @@nanovg_import_done
  end

  def self.import_symbols(render_backend)
    #
    # Common API
    #
    attach_function :BeginFrame, :nvgBeginFrame, [:pointer, :float, :float, :float], :void
    attach_function :CancelFrame, :nvgCancelFrame, [:pointer], :void
    attach_function :EndFrame, :nvgEndFrame, [:pointer], :void

    attach_function :GlobalCompositeOperation, :nvgGlobalCompositeOperation, [:pointer,  :int32], :void
    attach_function :GlobalCompositeBlendFunc, :nvgGlobalCompositeBlendFunc, [:pointer, :int32, :int32], :void
    attach_function :GlobalCompositeBlendFuncSeparate, :nvgGlobalCompositeBlendFuncSeparate, [:pointer, :int32, :int32, :int32, :int32], :void

    attach_function :RGB, :nvgRGB, [:uint8, :uint8, :uint8], Color.by_value
    attach_function :RGBf, :nvgRGBf, [:float, :float, :float], Color.by_value
    attach_function :RGBA, :nvgRGBA, [:uint8, :uint8, :uint8, :uint8], Color.by_value
    attach_function :RGBAf, :nvgRGBAf, [:float, :float, :float, :float], Color.by_value

    attach_function :LerpRGBA, :nvgLerpRGBA, [Color.by_value, Color.by_value, :float], Color.by_value
    attach_function :TransRGBA, :nvgTransRGBA, [Color.by_value, :uint8], Color.by_value
    attach_function :TransRGBAf, :nvgTransRGBAf, [Color.by_value, :float], Color.by_value
    attach_function :HSL, :nvgHSL, [:float, :float, :float], Color.by_value
    attach_function :HSLA, :nvgHSLA, [:float, :float, :float, :uint8], Color.by_value

    attach_function :Save, :nvgSave, [:pointer], :void
    attach_function :Restore, :nvgRestore, [:pointer], :void
    attach_function :Reset, :nvgReset, [:pointer], :void

    attach_function :ShapeAntiAlias, :nvgShapeAntiAlias, [:pointer, Color.by_value], :void
    attach_function :StrokeColor, :nvgStrokeColor, [:pointer, Color.by_value], :void
    attach_function :StrokePaint, :nvgStrokePaint, [:pointer, Paint.by_value], :void
    attach_function :FillColor, :nvgFillColor, [:pointer, Color.by_value], :void
    attach_function :FillPaint, :nvgFillPaint, [:pointer, Paint.by_value], :void
    attach_function :MiterLimit, :nvgMiterLimit, [:pointer, :float], :void
    attach_function :StrokeWidth, :nvgStrokeWidth, [:pointer, :float], :void
    attach_function :LineCap, :nvgLineCap, [:pointer, :int32], :void
    attach_function :LineJoin, :nvgLineJoin, [:pointer, :int32], :void
    attach_function :GlobalAlpha, :nvgGlobalAlpha, [:pointer, :float], :void

    attach_function :ResetTransform, :nvgResetTransform, [:pointer], :void
    attach_function :Transform, :nvgTransform, [:pointer, :float, :float, :float, :float, :float, :float], :void
    attach_function :Translate, :nvgTranslate, [:pointer, :float, :float], :void
    attach_function :Rotate, :nvgRotate, [:pointer, :float], :void
    attach_function :SkewX, :nvgSkewX, [:pointer, :float], :void
    attach_function :SkewY, :nvgSkewY, [:pointer, :float], :void
    attach_function :Scale, :nvgScale, [:pointer, :float, :float], :void
    attach_function :CurrentTransform, :nvgCurrentTransform, [:pointer, :pointer], :void

    attach_function :TransformIdentity, :nvgTransformIdentity, [:pointer], :void
    attach_function :TransformTranslate, :nvgTransformTranslate, [:pointer, :float, :float], :void
    attach_function :TransformScale, :nvgTransformScale, [:pointer, :float, :float], :void
    attach_function :TransformRotate, :nvgTransformRotate, [:pointer, :float], :void
    attach_function :TransformSkewX, :nvgTransformSkewX, [:pointer, :float], :void
    attach_function :TransformSkewY, :nvgTransformSkewY, [:pointer, :float], :void
    attach_function :TransformMultiply, :nvgTransformMultiply, [:pointer, :pointer], :void
    attach_function :TransformPremultiply, :nvgTransformPremultiply, [:pointer, :pointer], :void
    attach_function :TransformInverse, :nvgTransformInverse, [:pointer, :pointer], :int32
    attach_function :TransformPoint, :nvgTransformPoint, [:pointer, :pointer, :pointer, :float, :float], :void

    attach_function :DegToRad, :nvgDegToRad, [:float], :float
    attach_function :RadToDeg, :nvgRadToDeg, [:float], :float

    attach_function :CreateImage, :nvgCreateImage, [:pointer, :pointer, :int32], :int32
    attach_function :CreateImageMem, :nvgCreateImageMem, [:pointer, :int32, :pointer, :int32], :int32
    attach_function :CreateImageRGBA, :nvgCreateImageRGBA, [:pointer, :int32, :int32, :int32, :pointer], :int32
    attach_function :UpdateImage, :nvgUpdateImage, [:pointer, :int32, :pointer], :void
    attach_function :ImageSize, :nvgImageSize, [:pointer, :int32, :pointer, :pointer], :void
    attach_function :DeleteImage, :nvgDeleteImage, [:pointer, :int32], :void

    attach_function :LinearGradient, :nvgLinearGradient, [:pointer, :float, :float, :float, :float, Color.by_value, Color.by_value], Paint.by_value
    attach_function :BoxGradient, :nvgBoxGradient, [:pointer, :float, :float, :float, :float, :float, :float, Color.by_value, Color.by_value], Paint.by_value
    attach_function :RadialGradient, :nvgRadialGradient, [:pointer, :float, :float, :float, :float, Color.by_value, Color.by_value], Paint.by_value
    attach_function :ImagePattern, :nvgImagePattern, [:pointer, :float, :float, :float, :float, :float, :int32, :float], Paint.by_value

    attach_function :Scissor, :nvgScissor, [:pointer, :float, :float, :float, :float], :void
    attach_function :IntersectScissor, :nvgIntersectScissor, [:pointer, :float, :float, :float, :float], :void
    attach_function :ResetScissor, :nvgResetScissor, [:pointer], :void

    attach_function :BeginPath, :nvgBeginPath, [:pointer], :void
    attach_function :MoveTo, :nvgMoveTo, [:pointer, :float, :float], :void
    attach_function :LineTo, :nvgLineTo, [:pointer, :float, :float], :void
    attach_function :BezierTo, :nvgBezierTo, [:pointer, :float, :float, :float, :float, :float, :float], :void
    attach_function :QuadTo, :nvgQuadTo, [:pointer, :float, :float, :float, :float], :void
    attach_function :ArcTo, :nvgArcTo, [:pointer, :float, :float, :float, :float, :float], :void
    attach_function :ClosePath, :nvgClosePath, [:pointer], :void
    attach_function :PathWinding, :nvgPathWinding, [:pointer, :int32], :void
    attach_function :Arc, :nvgArc, [:pointer, :float, :float, :float, :float, :float, :int32], :void
    attach_function :Rect, :nvgRect, [:pointer, :float, :float, :float, :float], :void
    attach_function :RoundedRect, :nvgRoundedRect, [:pointer, :float, :float, :float, :float, :float], :void
    attach_function :RoundedRectVarying, :nvgRoundedRectVarying, [:pointer, :float, :float, :float, :float, :float, :float, :float, :float], :void
    attach_function :Ellipse, :nvgEllipse, [:pointer, :float, :float, :float, :float], :void
    attach_function :Circle, :nvgCircle, [:pointer, :float, :float, :float], :void
    attach_function :Fill, :nvgFill, [:pointer], :void
    attach_function :Stroke, :nvgStroke, [:pointer], :void

    attach_function :CreateFont, :nvgCreateFont, [:pointer, :pointer, :pointer], :int32
    attach_function :CreateFontMem, :nvgCreateFontMem, [:pointer, :pointer, :pointer, :int32, :int32], :int32
    attach_function :FindFont, :nvgFindFont, [:pointer, :pointer], :int32
    attach_function :AddFallbackFontId, :nvgAddFallbackFontId, [:pointer, :int32, :int32], :int32
    attach_function :AddFallbackFont, :nvgAddFallbackFont, [:pointer, :pointer, :pointer], :int32
    attach_function :FontSize, :nvgFontSize, [:pointer, :float], :void
    attach_function :FontBlur, :nvgFontBlur, [:pointer, :float], :void
    attach_function :TextLetterSpacing, :nvgTextLetterSpacing, [:pointer, :float], :void
    attach_function :TextLineHeight, :nvgTextLineHeight, [:pointer, :float], :void
    attach_function :TextAlign, :nvgTextAlign, [:pointer, :int32], :void
    attach_function :FontFaceId, :nvgFontFaceId, [:pointer, :int32], :void
    attach_function :FontFace, :nvgFontFace, [:pointer, :pointer], :void
    attach_function :Text, :nvgText, [:pointer, :float, :float, :pointer, :pointer], :float
    attach_function :TextBox, :nvgTextBox, [:pointer, :float, :float, :float, :pointer, :pointer], :void
    attach_function :TextBounds, :nvgTextBounds, [:pointer, :float, :float, :pointer, :pointer, :pointer], :float
    attach_function :TextBoxBounds, :nvgTextBoxBounds, [:pointer, :float, :float, :float, :pointer, :pointer, :pointer], :void
    attach_function :TextGlyphPositions, :nvgTextGlyphPositions, [:pointer, :float, :float, :pointer, :pointer, :pointer, :int32], :int32
    attach_function :TextMetrics, :nvgTextMetrics, [:pointer, :pointer, :pointer, :pointer], :void
    attach_function :TextBreakLines, :nvgTextBreakLines, [:pointer, :pointer, :pointer, :float, :pointer, :int32], :int32

    #
    # GL2-specific API (nanovg_gl)
    #
    if render_backend == :gl2
      attach_function :CreateGL2, :nvgCreateGL2, [:int32], :pointer
      attach_function :DeleteGL2, :nvgDeleteGL2, [:pointer], :void
      attach_function :SetupGL2, :nvgSetupGL2, [], :void
    end

    #
    # GL3-specific API (nanovg_gl)
    #
    if render_backend == :gl3
      attach_function :CreateGL3, :nvgCreateGL3, [:int32], :pointer
      attach_function :DeleteGL3, :nvgDeleteGL3, [:pointer], :void
      attach_function :SetupGL3, :nvgSetupGL3, [], :void
    end

    @@nanovg_import_done = true
  end
end

=begin
NanoVG-Bindings : A Ruby bindings of NanoVG
Copyright (c) 2015-2025 vaiorabbit

This software is provided 'as-is', without any express or implied
warranty. In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

    1. The origin of this software must not be misrepresented; you must not
    claim that you wrote the original software. If you use this software
    in a product, an acknowledgment in the product documentation would be
    appreciated but is not required.

    2. Altered source versions must be plainly marked as such, and must not be
    misrepresented as being the original software.

    3. This notice may not be removed or altered from any source
    distribution.
=end
