class RayTracer
    gl = null
    constructor: ->
        @canvas = document.createElement("canvas")

        gl = @canvas.getContext("webgl2")
        return if not gl

        @createBuffers()
        @createShaders()


    createBuffers: ->
        @screenVBO = GLCommon.createBuffer(gl, new Float32Array([
            -1, -1, -1, +1, +1, +1, +1, +1, +1, -1, -1, -1
        ]), gl.STATIC_DRAW)


    createShaders: ->
        vert = [gl.VERTEX_SHADER,   RayTracer.vertShaderSource]
        frag = [gl.FRAGMENT_SHADER, RayTracer.fragShaderSource]

        @program = GLCommon.createShader(gl, [vert, frag])

        gl.useProgram(@program)
        @vertPosAttrib = gl.getAttribLocation(@program, "vertPos")
        gl.bindBuffer(gl.ARRAY_BUFFER, @screenVBO)
        gl.enableVertexAttribArray(@vertPosAttrib)
        gl.vertexAttribPointer(@vertPosAttrib, 2, gl.FLOAT, false, Float32Array.BYTES_PER_ELEMENT * 2, 0)


    render: ->
        gl.viewport(0, 0, @canvas.width, @canvas.height)
        gl.clearColor(0.5, 0.5, 0.5, 1.0)
        gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

        gl.useProgram(@program)

        gl.drawArrays(gl.TRIANGLES, 0, 6)
