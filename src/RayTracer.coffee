class RayTracer
    gl = null
    constructor: ->
        @canvas = document.createElement("canvas")

        gl = @canvas.getContext("webgl2")
        return if gl is null

        @screenVBO = new Buffer(gl, new Float32Array([
            -1, -1, -1, +1, +1, +1, +1, +1, +1, -1, -1, -1
        ]))

        sources = [
            [gl.VERTEX_SHADER,   RayTracer.vertShaderSource]
            [gl.FRAGMENT_SHADER, RayTracer.fragShaderSource]
        ]

        uniforms = [
            "cullDistance",
            "floatBufferSampler",
            "floatBufferAddressShift",
            "floatBufferAddressMask",
            "triangleAddressEnd"
        ]

        @program = new ShaderProgram(gl, sources, uniforms, ["vertPos"])
        @program.use()

        gl.uniform1f(@program.uniforms.cullDistance, 10000)
        gl.uniform1i(@program.uniforms.floatBufferSampler, 0)
        gl.uniform1ui(@program.uniforms.floatBufferAddressMask, 2 - 1)
        gl.uniform1ui(@program.uniforms.floatBufferAddressShift, 1)
        gl.uniform1ui(@program.uniforms.triangleAddressEnd, 6)

        @screenVBO.bind()
        gl.enableVertexAttribArray(@program.uniforms.vertPos)
        gl.vertexAttribPointer(@program.uniforms.vertPos, 2, gl.FLOAT, false, 0, 0)

        floatBuffer = new Float32Array([
            0.0, 0.0, 2.0, 0.0,
            1.0, 0.0, 0.0, 0.0,
            0.0, 1.0, 0.0, 0.0,
            1.0, 1.0, 3.0, 0.0,
            -3.0, 0.0, 0.0, 0.0,
            0.0, -3.0, 0.0, 0.0,
            0.0, 0.0, 0.0, 0.0,
            0.0, 0.0, 0.0, 0.0
        ]);

        @floatBufferTex = new Texture(gl, 2, 4, gl.RGBA32F, gl.RGBA, gl.FLOAT, floatBuffer)


    render: ->
        gl.viewport(0, 0, @canvas.width, @canvas.height)
        gl.clearColor(0.5, 0.5, 0.5, 1.0)
        gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

        @floatBufferTex.bind(gl.TEXTURE0)

        @program.use()
        gl.drawArrays(gl.TRIANGLES, 0, 6)
