#!vanilla

# Canvas id (html element)
canvasId = "canvas" 

# Color mapping
log10 = (x) -> Math.log(x)/Math.LN10
$blab.colorMap =
    # Hue is a function of angle.
    # Saturation/lightness/opacity are functions of radius:
    saturation: (r) -> 1
    lightness: (r) -> 0.5 * (1 - 1 / (1 + 25*log10(2*r + 1)))
    opacity: (r) -> 1 / (1 + 1*log10(1+2*r))
    
sliderText = (val) ->
    $("#slider_text").html "a=#{val}" 
        
# Render complex function.
$blab.complexFunction = (spec) ->
    
    f = spec.f
    xMax = spec.xMax
    
    $(document).trigger "reprocessHtml"
        
    $("#slider").slider(
        min: spec.a.min
        max: spec.a.max
        step: spec.a.step
        value: spec.a.init
        slide: (e, ui) -> sliderText ui.value           
        change: (e, ui) ->
            a = ui.value
            sliderText a
            drawFunction a   
    ) if spec.a?
        
    drawFunction = (a) ->
        if a?
            f = (z) -> spec.f z, a
        new $blab.ComplexFunctionImage {f, xMax, canvasId}, $blab.colorMap
        
    if spec.a?
        a = spec.a.init
        sliderText a
        drawFunction a
    else
        drawFunction()
    $("#mathjax").html("$f(z) = #{spec.mathJax}$")
    $(document).trigger "htmlOutputUpdated"
        
# Example usage (see also HTML/CSS):
# Need to remove vanilla directive to use these examples.

# mathJax = "z^a"  # MathJax for function
# f = (z, a=1) -> z.pow a  # Code for function
# a = {min: 1, max: 10, step: 1, init: 2} 
# xMax = 2.5  # Maximum domain value for real/imaginary parts.
# $blab.complexFunction {f, a, xMax, mathJax}

# Or, without parameter
# mathJax = "z^3"  # MathJax for function
# f = (z) -> z.pow 3  # Code for function
# xMax = 2.5  # Maximum domain value for real/imaginary parts.
# $blab.complexFunction {f, xMax, mathJax}

#!end (coffee)

