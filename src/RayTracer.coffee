class RayTracer
    gl = null
    constructor: ->
        @canvas = document.createElement("canvas")

        gl = @canvas.getContext("webgl2")
        if gl is null
            throw "Unable to create WebGL2 context"

        @scene = new Scene(gl)

        # Generate random test triangles for testing
        @scene.addTriangles(
            for i in [0...100]
                r = -> Math.random() * 2 - 1
                new Triangle(
                    new Vec3(r(), r(), r()),
                    new Vec3(r(), r(), r()),
                    new Vec3(r(), r(), r())
                )
        )

        @createShader()

        @screenVBO = new Buffer(gl, new Float32Array([
            -1, -1, -1, +1, +1, +1,
            +1, +1, +1, -1, -1, -1
        ]))

        @vao = new VertexArray(gl)
        @vao.setupAttrib(@program.uniforms.vertPos, @screenVBO, 2, gl.FLOAT, 0, 0)


    createShader: ->
        sources = [
            [gl.VERTEX_SHADER,   RayTracer.vertShaderSource]
            [gl.FRAGMENT_SHADER, RayTracer.fragShaderSource]
        ]

        uniforms = [
            "cullDistance",
            "cameraPosition"
            "floatBufferSampler",
            "floatBufferAddressShift",
            "floatBufferAddressMask",
            "triangleAddressEnd"
        ]

        @program = new ShaderProgram(gl, sources, uniforms, ["vertPos"])
        @program.use()

        gl.uniform1f(@program.uniforms.cullDistance, 10000)
        gl.uniform3f(@program.uniforms.cameraPosition, 0, 0, -2)


    setupTextureDataBuffers: ->
        @scene.triangleDataTex.bind(gl.TEXTURE0)
        gl.uniform1i(@program.uniforms.floatBufferSampler, 0)
        gl.uniform1ui(@program.uniforms.floatBufferAddressMask,  @scene.triangleDataTex.dataMask)
        gl.uniform1ui(@program.uniforms.floatBufferAddressShift, @scene.triangleDataTex.dataShift)
        gl.uniform1ui(@program.uniforms.triangleAddressEnd, @scene.triangleAddressEnd)


    render: ->
        gl.viewport(0, 0, @canvas.width, @canvas.height)
        gl.clearColor(1.0, 1.0, 1.0, 1.0)
        gl.clear(gl.COLOR_BUFFER_BIT)

        @setupTextureDataBuffers()

        @program.use()
        @vao.bind()

        gl.drawArrays(gl.TRIANGLES, 0, 6)
