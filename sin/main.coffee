log10 = (x) -> Math.log(x)/Math.LN10

colorMap =
    saturation: (r) -> 1
    lightness: (r) -> 0.5 * (1 - 1 / (1 + 25*log10(2*r + 1)))
    opacity: (r) -> 4 / (1 + 4*log10(1+2*r))    

new $blab.ComplexFunctionImage
    colorMap: colorMap
    xMax: 2
    f: (z) -> sin(3*z)
