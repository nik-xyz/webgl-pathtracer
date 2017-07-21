class PathTracer
    gl = null
    vao = null
    screenVBO = null
    program = null
    framebuffer = null

    constructor: ->
        @canvas = document.createElement("canvas")

        attribs = {
            antialias: false
            depth: false
            stencil: false
        }
        gl = @canvas.getContext("webgl2", attribs)
        if gl is null then throw "Unable to create WebGL2 context"

        screenVBO = new Buffer(gl, new Float32Array(
            [-1, -1, -1, +1, +1, +1, +1, +1, +1, -1, -1, -1]
        ))

        program = createShader()
        @createScene()

        vao = new VertexArray(gl)
        vao.setupAttrib(program.uniforms.vertPos, screenVBO, 2, gl.FLOAT, 0, 0)

        @sampleCounter = 0


    setResolution: (@resolution) ->
        [@canvas.width, @canvas.height] = @resolution.array()

        framebuffer = new TexFramebuffer(gl, @resolution)


    createShader = ->
        sources = [
            [gl.VERTEX_SHADER,   ShaderSources.getVertShaderSource()]
            [gl.FRAGMENT_SHADER, ShaderSources.getFragShaderSource()]
        ]

        uniforms = [
            "cameraPosition"
            "subPixelJitter"

            "octreeCubeCenter"
            "octreeCubeSize"

            "octreeBufferSampler"
            "octreeBufferShift"
            "octreeBufferMask"

            "triangleBufferSampler"
            "triangleBufferShift"
            "triangleBufferMask"

            "randomBufferSampler"
            "randomBufferShift"
            "randomBufferMask"

            "compositeAlpha"
        ]

        attribs = ["vertPos"]

        return new ShaderProgram(gl, sources, uniforms, attribs)


    createScene: ->
        triangles = new TriangleLoader(Models.testModel).triangles

        @octree = new Octree(triangles)
        [octreeBuffer, triangleBuffer] = @octree.encode()

        @octreeDataTex   = new DataTexture(gl, gl.UNSIGNED_INT, octreeBuffer)
        @triangleDataTex = new DataTexture(gl, gl.FLOAT, triangleBuffer)


    createRandomData: ->
        randomDataLen = 1 << 12
        randomData = [0...randomDataLen].map(Math.random)
        if @randomDataTex?
            gl.deleteTexture(@randomDataTex.tex)

        @randomDataTex = new DataTexture(gl, gl.FLOAT, randomData)



    renderImage: ->
        @createRandomData()

        gl.viewport(0, 0, @resolution.x, @resolution.y)

        program.use()
        vao.bind()

        gl.bindFramebuffer(gl.DRAW_FRAMEBUFFER, framebuffer.buf)
        gl.bindFramebuffer(gl.READ_FRAMEBUFFER, framebuffer.buf)

        @triangleDataTex.bind(gl.TEXTURE0)
        @octreeDataTex.bind(gl.TEXTURE1)
        @randomDataTex.bind(gl.TEXTURE2)

        gl.uniform1i( program.uniforms["triangleBufferSampler"], 0)
        gl.uniform1ui(program.uniforms["triangleBufferMask"],  @triangleDataTex.dataMask)
        gl.uniform1ui(program.uniforms["triangleBufferShift"], @triangleDataTex.dataShift)

        gl.uniform1i( program.uniforms["octreeBufferSampler"], 1)
        gl.uniform1ui(program.uniforms["octreeBufferMask"],  @octreeDataTex.dataMask)
        gl.uniform1ui(program.uniforms["octreeBufferShift"], @octreeDataTex.dataShift)

        gl.uniform1i( program.uniforms["randomBufferSampler"], 2)
        gl.uniform1ui(program.uniforms["randomBufferMask"],  @randomDataTex.dataMask)
        gl.uniform1ui(program.uniforms["randomBufferShift"], @randomDataTex.dataShift)

        gl.uniform3fv(program.uniforms["octreeCubeCenter"], @octree.root.center.array())
        gl.uniform1f(program.uniforms["octreeCubeSize"], @octree.root.size)

        gl.uniform1f(program.uniforms["cullDistance"], 10000)
        gl.uniform3f(program.uniforms["cameraPosition"], 0, 3, -3)
        gl.uniform2uiv(program.uniforms["resolution"], @resolution.array())

        jitter = new Vec2().map(-> Math.random() * 2 - 1).div(@resolution)
        gl.uniform2fv(program.uniforms["subPixelJitter"], jitter.array())
        gl.uniform1f(program.uniforms["compositeAlpha"], 1 / (@sampleCounter + 1))

        @sampleCounter++

        gl.enable(gl.BLEND)
        gl.blendFuncSeparate(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA, gl.ONE, gl.ONE)

        gl.depthMask(false)
        gl.drawArrays(gl.TRIANGLES, 0, 6)
        gl.finish()


    displayImage: ->
        gl.bindFramebuffer(gl.READ_FRAMEBUFFER, framebuffer.buf)
        gl.bindFramebuffer(gl.DRAW_FRAMEBUFFER, null)
        gl.clearColor(0, 0, 0, 0)
        gl.clear(gl.COLOR_BUFFER_BIT)
        bounds = [0, 0, @resolution.x, @resolution.y]
        gl.blitFramebuffer(bounds..., bounds..., gl.COLOR_BUFFER_BIT, gl.NEAREST)
