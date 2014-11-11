log10 = (x) -> Math.log(x)/Math.LN10

colorMap =
    saturation: (r) -> 1
    lightness: (r) -> 0.5 * (1 - 1 / (1 + 25*log10(2*r + 1)))
    opacity: (r) -> 1 / (1 + 4*log10(1+2*r))    

canvasId = "canvas"
f = (z) -> z*z
xMax = 2
new $blab.ComplexFunctionImage {canvasId, f, xMax}, colorMap
