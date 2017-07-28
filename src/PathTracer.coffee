class PathTracer
    constructor: ->
        @createContext()
        @createShader()
        @createVertexData()
        @reset()

        @scene = new Scene(@gl)
        @randomGen = new RandomGen(@gl)


    createContext: ->
        # Disable features that intefere with pixel transfer operations
        # or are not needed
        attribs =
            antialias: false
            depth:     false
            stencil:   false
            alpha:     false

        @gl = document.createElement("canvas")?.getContext("webgl2", attribs)
        unless @gl then throw "Unable to create WebGl2 context"

        @gl.depthMask(false)
        @gl.clearColor(0, 0, 0, 0)


    createShader: ->
        sources = [
            [@gl.VERTEX_SHADER,   ShaderSources.getVertShaderSource()]
            [@gl.FRAGMENT_SHADER, ShaderSources.getFragShaderSource()]
        ]
        @program = new ShaderProgram(@gl, sources,
                ShaderSources.uniformNames, ["vertPos"])


    createVertexData: ->
        @vbo = new Buffer(@gl, new Float32Array(
            [-1, -1, -1, +1, +1, +1, +1, +1, +1, -1, -1, -1]
        ))
        @vao = new VertexArray(@gl)
        @vao.setupAttrib(@program.uniforms["vertPos"], @vbo, 2, @gl.FLOAT)


    reset: ->
        @sampleCounter = 0


    getCanvas: ->
        @gl.canvas


    setResolution: (@frameRes) ->
        @frameBounds = [0, 0, @frameRes.x, @frameRes.y]
        [@gl.canvas.width, @gl.canvas.height] = @frameRes.array()
        @gl.viewport(@frameBounds...)

        if @frame? then @frame.destroy()
        @frame = new TexFramebuffer(@gl, @frameRes)

        @reset()


    setJitter: ->
        jitter = new Vec2()
            .map(Math.random)
            .scale(2)
            .sub(new Vec2(1, 1))
            .div(@frameRes)
            .array()

        @gl.uniform2fv(@program.uniforms["subPixelJitter"], jitter)


    setAlpha: ->
        runningAverageAlpha = 1 / (@sampleCounter + 1)
        @gl.uniform1f(@program.uniforms["compositeAlpha"], runningAverageAlpha)


    renderImage: ->
        @program.use()

        @randomGen.createRandomData()
        @randomGen.bind(@program)
        @scene.bind(@program)

        @setJitter()
        @setAlpha()

        @sampleCounter++

        # Render to output framebugger
        @gl.bindFramebuffer(@gl.DRAW_FRAMEBUFFER, @frame.buf)
        @gl.bindFramebuffer(@gl.READ_FRAMEBUFFER, @frame.buf)

        # Composite samples with additive blending
        @gl.enable(@gl.BLEND)
        @gl.blendFuncSeparate(@gl.SRC_ALPHA, @gl.ONE_MINUS_SRC_ALPHA,
            @gl.ONE, @gl.ONE)

        # Render
        @vao.bind()
        @gl.drawArrays(@gl.TRIANGLES, 0, 6)
        @gl.finish()


    displayImage: ->
        @gl.bindFramebuffer(@gl.READ_FRAMEBUFFER, @frame.buf)
        @gl.bindFramebuffer(@gl.DRAW_FRAMEBUFFER, null)

        @gl.clear(@gl.COLOR_BUFFER_BIT)

        @gl.blitFramebuffer(@frameBounds..., @frameBounds...,
            @gl.COLOR_BUFFER_BIT, @gl.NEAREST)
