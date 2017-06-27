class RayTracer
    gl = null
    constructor: ->
        @canvas = document.createElement("canvas")

        gl = @canvas.getContext("webgl2")
        return if gl is null

        @screenVBO = new Buffer(gl, new Float32Array([
            -1, -1, -1, +1, +1, +1, +1, +1, +1, -1, -1, -1
        ]))

        vert = [gl.VERTEX_SHADER,   RayTracer.vertShaderSource]
        frag = [gl.FRAGMENT_SHADER, RayTracer.fragShaderSource]
        @program = new ShaderProgram(gl, [vert, frag], [], ["vertPos"])

        @screenVBO.bind()
        gl.enableVertexAttribArray(@program.uniforms.vertPos)
        gl.vertexAttribPointer(@program.uniforms.vertPos, 2, gl.FLOAT, false, 0, 0)


    render: ->
        gl.viewport(0, 0, @canvas.width, @canvas.height)
        gl.clearColor(0.5, 0.5, 0.5, 1.0)
        gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

        @program.use()
        gl.drawArrays(gl.TRIANGLES, 0, 6)
