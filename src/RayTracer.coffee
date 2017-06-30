class RayTracer
    gl = null
    constructor: ->
        @canvas = document.createElement("canvas")

        gl = @canvas.getContext("webgl2")
        if gl is null
            throw "Unable to create WebGL2 context"


        screenVerts = [-1, -1, -1, +1, +1, +1, +1, +1, +1, -1, -1, -1]
        @screenVBO = new Buffer(gl, new Float32Array(screenVerts))

        @createShader()
        @createDataTextures()

        @vao = new VertexArray(gl)
        @vao.setupAttrib(@program.uniforms.vertPos, @screenVBO, 2, gl.FLOAT, 0, 0)


    createShader: ->
        sources = [
            [gl.VERTEX_SHADER,   RayTracer.vertShaderSource]
            [gl.FRAGMENT_SHADER, RayTracer.fragShaderSource]
        ]

        uniforms = [
            "cullDistance"
            "cameraPosition"

            "octreeBufferSampler"
            "octreeBufferShift"
            "octreeBufferMask"

            "triangleBufferSampler"
            "triangleBufferShift"
            "triangleBufferMask"
        ]

        @program = new ShaderProgram(gl, sources, uniforms, ["vertPos"])
        @program.use()

        gl.uniform1f(@program.uniforms.cullDistance, 10000)
        gl.uniform3f(@program.uniforms.cameraPosition, 0, 0, -2)


    createDataTextures: ->
        # Generate random triangles for testing
        triangles =
            for i in [0...100]
                r = (s = 0.2) -> s * (Math.random() * 2 - 1)
                o = new Vec3(r(1), r(1), r(1))
                new Triangle([0...3].map(-> new Vec3(r(), r(), r()).add(o))...)

        @octree = new Octree(triangles)
        [octreeBuffer, triangleBuffer] = @octree.encode()

        @octreeDataTex = new DataTexture(gl, gl.UNSIGNED_INT,
            Octree.OCTREE_BUFFER_CHANNELS, octreeBuffer)
        @triangleDataTex = new DataTexture(gl, gl.FLOAT,
            Octree.TRIANGLE_BUFFER_CHANNELS, triangleBuffer)


    bindDataTextures: ->
        uniforms = @program.uniforms

        @triangleDataTex.bind(gl.TEXTURE0)
        gl.uniform1i(uniforms.triangleBufferSampler, 0)
        gl.uniform1ui(uniforms.triangleBufferMask,  @triangleDataTex.dataMask)
        gl.uniform1ui(uniforms.triangleBufferShift, @triangleDataTex.dataShift)

        @octreeDataTex.bind(gl.TEXTURE1)
        gl.uniform1i(uniforms.octreeBufferSampler, 1)
        gl.uniform1ui(uniforms.octreeBufferMask,  @octreeDataTex.dataMask)
        gl.uniform1ui(uniforms.octreeBufferShift, @octreeDataTex.dataShift)


    render: ->
        gl.viewport(0, 0, @canvas.width, @canvas.height)
        gl.clearColor(1.0, 1.0, 1.0, 1.0)
        gl.clear(gl.COLOR_BUFFER_BIT)

        @bindDataTextures()

        @program.use()
        @vao.bind()

        gl.drawArrays(gl.TRIANGLES, 0, 6)
