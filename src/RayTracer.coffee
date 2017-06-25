class RayTracer
    gl = null
    constructor: ->
        @canvas = document.createElement("canvas")

        gl = @canvas.getContext("webgl")
        return if not gl

        @createShaders()


    createShaders: ->
        vert = [gl.VERTEX_SHADER,   ShaderSources.vertex]
        frag = [gl.FRAGMENT_SHADER, ShaderSources.fragment]

        shaders =
            for [type, source] in [frag, vert]
                shader = gl.createShader(type)

                gl.shaderSource(shader, source)
                gl.compileShader(shader)

                shader

        @program = gl.createProgram()

        for shader in shaders
            gl.attachShader(@program, shader)

        gl.linkProgram(@program)

        for shader in shaders
            gl.detachShader(@program, shader)
            gl.deleteShader(shader)


    render: ->
        gl.viewport(0, 0, @canvas.width, @canvas.height)
        gl.clearColor(0.5, 0.5, 0.5, 1.0)
        gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
