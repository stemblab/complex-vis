#!vanilla
plotFunction = ->
    canvasId = "canvas"
    f = identity
    xMax = 2
    new ComplexFunctionImage {canvasId, f, xMax}, colorMap

colorMap =
    saturation: (r) -> 1
    lightness: (r) -> 0.5 * (1 - 1 / (1 + 25*log10(2*r + 1)))
    opacity: (r) -> 1 / (1 + 4*log10(1+2*r))    

complex = numeric.complex
log10 = (x) -> Math.log(x)/Math.LN10

identity = (z) -> z

# Comment vanilla directive to use these functions (overloaded ops).
square = (z) -> z*z

cube = (z) -> z*z*z

class ComplexFunctionImage

    constructor: (@spec, @colorMap) ->
        # spec:
        #   canvasId
        #   pixelsPerSquare
        #   f (complex function)
        #   xMin, xMax, yMin, yMax
        # colorMap:
        #   saturation, lightness, opacity (functions of r)
        
        # Canvas
        @pixelsPerSquare = @spec.pixelsPerSquare ? 2
        @image = new Image @spec.canvasId, @pixelsPerSquare
        @pxMax = @image.xMax()
        @pyMax = @image.yMax()

        # Complex function
        @f = @spec.f
        @xMax = @spec.xMax
        @xMin = @spec.xMin ? -@xMax
        @yMax = @spec.yMax ? @xMax
        @yMin = @spec.yMin ? -@yMax
        
        # Domain scaling
        @kx = (@xMax - @xMin)/(@pxMax-1)
        @ky = (@yMax - @yMin)/(@pyMax-1)
        
        @plot()
        
    plot: ->
        for px in [0..@pxMax-1]
            x = @kx*px + @xMin
            for py in [0..@pyMax-1]
                y = -(@ky*py + @yMin)
                z = complex x, y
                zf = @f z
                v = zf.abs().x
                hsla =
                    h: @angle zf
                    s: @colorMap.saturation v
                    l: @colorMap.lightness v
                    a: @colorMap.opacity v
                @image.setSquareHsla px, py, hsla
        
    angle: (z) ->
        # Angle (degrees)
        pi = Math.PI
        a = Math.atan2(z.y, z.x)  # -pi to pi
        a += 2*pi if a<0  # 0 to 2pi
        360/(2*pi)*a
        
class Image

    constructor: (@canvasId, @pixelsPerSquare=1) ->
        @element = document.getElementById @canvasId
        @width = @element.width
        @height = @element.height
        @element.width = @width  # Clears canvas
        @ctx = @element.getContext "2d"
        
    setSquare: (x, y, col="red") ->
        p = @pixelsPerSquare
        @ctx.fillStyle = col
        @ctx.fillRect p*x, p*y, p, p
        
    setSquareHsla: (x, y, hsla) ->
        col = 
            "hsla(#{hsla.h}, "+
            "#{100*hsla.s}%, "+
            "#{100*hsla.l}%, "+
            "#{hsla.a})"
        @setSquare x, y, col
        
    setSquareFromMap: (x, y, hue, map, r, m=1) ->
        sat = 1
        light = map.lightness r, m
        opacity = map.opacity r, m
        @setSquareHsla x, y, {h: hue, s: sat, l: light, a: opacity}        
        
    xMax: -> @width/@pixelsPerSquare
    yMax: -> @height/@pixelsPerSquare

$blab.ComplexFunctionImage = ComplexFunctionImage
#plotFunction()

#!end (coffee)

