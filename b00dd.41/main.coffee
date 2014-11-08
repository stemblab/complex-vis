#!vanilla
class MainComplexFunction

    selectGalleryExample: "selectGalleryExample"

    constructor: ->
        @doc = $ document
        @doc.trigger "reprocessHtml"
        @canvasId = "canvas"
        @doc.unbind @selectGalleryExample
        @first = true
        @doc.on @selectGalleryExample, (e, data) =>
            @func?.text "Loading..."
            # Delay so loading message displayed.
            setTimeout (=> @setExample data.functionSpec, data.id), 10
    
    setExample: (functionSpec, id) ->
        @draw functionSpec, id
        if @first
            @animate functionSpec
            @first = false
        else
            @changed = true        
    
    draw: (functionSpec, id) ->
        $("#canvas_link").attr href: "/m/#{id}"
        spec = $.extend {}, functionSpec  # Clone
        spec.canvasId = @canvasId
        spec.mathJaxContainer = $ "#mathjax"
        spec.sliderContainer = $ "#slider"
        spec.sliderText = $ "#slider_text"
        @func = new ComplexFunction spec
        @doc.trigger "htmlOutputUpdated"  # To re-render MathJax
    
    animate: (spec) ->
        a = spec.a
        setSlider = (v) =>
            return if @func.sliderTouched? or @changed?
            @func.setSliderVal v
            setTimeout (-> setSlider(v+a.step)), 1000 if v<a.max
        setSlider a.min

class Gallery

    # Blab id of examples to show in gallery
    examplesId: "b00dh"

    # Exclude these revisions from gallery
    excludeRevisions: [1]
    
    constructor: ->
        @div = $ "#examples"
        @examples = []
        @getRevisions()
                
    getRevisions: ->
        spec = 
            id: @examplesId
            action: "getLabRevisions"
        $blab.server.request spec, (resp) =>
            return unless resp.ok
            @div.empty()
            @examplesToLoad = 0
            @getRevision r.rev for r in resp.revisions
                
    getRevision: (rev) ->
        return if parseInt(rev) in @excludeRevisions
        id = "#{@examplesId}.#{rev}"
        @examplesToLoad++
        @examples.push(new GalleryExample @div, id, => @exampleLoaded())
                
    exampleLoaded: ->
        @examplesToLoad--
        @examples[0].select() if @examplesToLoad is 0  # All examples loaded

class GalleryExample

    constructor: (@container, @id, @loadedCallback) ->
        @html()
        @load()
        $(document).on "clickGalleryExample", (e, data) => @border(data.id is @id) 
          
    html: ->
        
        @div = $ "<div>", class: "example"
        @container.append @div
        
        @mathJaxContainer = $ "<div>", class: "mathjax_container"

        @canvasId = "canvas_"+@id
        @link = $ "<a>", click: => @select()
        @sliderContainer = $ "<div>", class: "slider_thumb"
        @sliderText = $ "<span>", class: "slider_text"
        
        @div
            .append(@mathJaxContainer)
            .append(@link)
            .append(@sliderContainer)
            .append(@sliderText)
        
        @canvas = $ "<canvas>",
            id: @canvasId
            class: "canvas"
            width: 120
            height: 120
            title: "Click to see larger image (at top)"
            
        @link.append @canvas
        @border false
        
    load: ->
        t = new Date().getTime()
        url = "/puzlet/php/source.php?pageId=#{@id}&file=main.coffee&t=#{t}"
            
        $.ajax(
            url: url
            type: "get"
        ).done (data) =>
            @runCoffee data
            @loadedCallback()
            
    runCoffee: (coffee) ->
        
        @js = CoffeeEvaluator.compile coffee
                
        # Global function used in imported/compiled CoffeeScript code.
        $blab.complexFunction = (@functionSpec) =>
            spec = $.extend({}, @functionSpec)  # Clone
            spec.canvasId = @canvasId
            spec.mathJaxContainer = @mathJaxContainer
            spec.link = @link
            spec.sliderContainer = @sliderContainer
            spec.sliderText = @sliderText
            new ComplexFunction spec
            
        eval @js
        
    select: ->
        @border()
        data =
            id: @id
            functionSpec: @functionSpec
        $.event.trigger "clickGalleryExample", data
        # Delay computation so borders can be set/unset.
        setTimeout (-> $.event.trigger "selectGalleryExample", data), 10
                
    border: (border=true) ->
        @canvas.css border: (if border then "2px solid blue" else "2px solid white") 
        
class ComplexFunction

    constructor: (@spec) ->
        
        # MathJax label
        mathJax = @spec.mathJax ? "?="       
        @spec.mathJaxContainer.html("$f(z) = #{mathJax}$")

        # Slider if parameter property specified
        if @spec.a?
            a = @spec.a
            @spec.sliderContainer.slider
                min: a.min
                max: a.max
                step: a.step
                value: a.init
                slide: (e, ui) =>
                    @sliderTouched = true
                    @setSliderText ui.value           
                change: (e, ui) => @draw ui.value
        
        # Draw complex function.
        @draw @spec.a?.init
            
    draw: (a) ->
        if a?
            @setSliderText a
            f = (z) => @spec.f z, a
        else
            f = @spec.f
        xMax = @spec.xMax
        canvasId = @spec.canvasId
        new $blab.ComplexFunctionImage {f, xMax, canvasId}, $blab.colorMap
        
    text: (txt) ->
        canvas = document.getElementById @spec.canvasId
        context = canvas.getContext "2d"
        context.fillStyle = "white"
        context.font = "bold 16px Arial"
        context.textAlign = "center"
        w = canvas.width
        h = canvas.height
        context.fillText txt, w/2, h/2
        
    setSliderVal: (a) ->
        @spec.sliderContainer.slider "value", a
        
    setSliderText: (val) => @spec.sliderText.html "a=#{val}"

new MainComplexFunction
new Gallery

#!end (coffee)

