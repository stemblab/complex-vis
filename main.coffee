 #1. <u>Define color mapping</u>.
log10 = (x) -> Math.log(x)/Math.LN10
colorMap =
    saturation: (r) -> 1
    lightness: (r) -> 0.5 * (1 - 1 / (1 + 25*log10(2*r + 1)))
    opacity: (r) -> 4 / (1 + 4*log10(1+2*r))    

 #2. <u>Define complex function</u>.
xMax = 2
f = (z) -> (z*z-1)*(z-2-j).pow(2)/(z*z+2+j)

 #3. <u>Plot</u>
 # Shift+enter (this panel must have focus). 
new $blab.ComplexFunctionImage
    colorMap: colorMap
    xMax: xMax
    f: f
