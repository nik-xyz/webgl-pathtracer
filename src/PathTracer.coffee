class PathTracer
    gl = null
    vao = null
    screenVBO = null
    program = null

    constructor: ->
        @canvas = document.createElement("canvas")

        gl = @canvas.getContext("webgl2")
        if gl is null then throw "Unable to create WebGL2 context"

        screenVBO = new Buffer(gl, new Float32Array(
            [-1, -1, -1, +1, +1, +1, +1, +1, +1, -1, -1, -1]
        ))

        program = createShader()
        @createDataTextures()

        vao = new VertexArray(gl)
        vao.setupAttrib(program.uniforms.vertPos, screenVBO, 2, gl.FLOAT, 0, 0)


    createShader = ->
        sources = [
            [gl.VERTEX_SHADER,   ShaderSources.getVertShaderSource()]
            [gl.FRAGMENT_SHADER, ShaderSources.getFragShaderSource()]
        ]

        uniforms = [
            "cameraPosition"

            "octreeCubeCenter"
            "octreeCubeSize"

            "octreeBufferSampler"
            "octreeBufferShift"
            "octreeBufferMask"

            "triangleBufferSampler"
            "triangleBufferShift"
            "triangleBufferMask"
        ]

        attribs = ["vertPos"]

        return new ShaderProgram(gl, sources, uniforms, attribs)


    createDataTextures: ->
        triangles = new TriangleLoader(Models.testModel).triangles

        @octree = new Octree(triangles)
        [octreeBuffer, triangleBuffer] = @octree.encode()

        @octreeDataTex   = new DataTexture(gl, gl.UNSIGNED_INT, octreeBuffer)
        @triangleDataTex = new DataTexture(gl, gl.FLOAT, triangleBuffer)


    render: ->
        gl.viewport(0, 0, @canvas.width, @canvas.height)

        program.use()

        @triangleDataTex.bind(gl.TEXTURE0)
        gl.uniform1i( program.uniforms["triangleBufferSampler"], 0)
        gl.uniform1ui(program.uniforms["triangleBufferMask"],  @triangleDataTex.dataMask)
        gl.uniform1ui(program.uniforms["triangleBufferShift"], @triangleDataTex.dataShift)

        @octreeDataTex.bind(gl.TEXTURE1)
        gl.uniform1i( program.uniforms["octreeBufferSampler"], 1)
        gl.uniform1ui(program.uniforms["octreeBufferMask"],  @octreeDataTex.dataMask)
        gl.uniform1ui(program.uniforms["octreeBufferShift"], @octreeDataTex.dataShift)

        gl.uniform3fv(program.uniforms["octreeCubeCenter"], @octree.root.center.array())
        gl.uniform1f(program.uniforms["octreeCubeSize"], @octree.root.size)

        gl.uniform1f(program.uniforms["cullDistance"], 10000)
        gl.uniform3f(program.uniforms["cameraPosition"], 0, 0, -5)

        vao.bind()
        gl.drawArrays(gl.TRIANGLES, 0, 6)
