class ShaderProgram
    constructor: (@gl, shaderData, uniformNames = [], attribNames = []) ->
        shaders = createShaders(@gl, shaderData)
        checkShaders(@gl, shaders)

        @program = @gl.createProgram()

        for shader in shaders
            @gl.attachShader(@program, shader)

        @gl.linkProgram(@program)

        for shader in shaders
            @gl.detachShader(@program, shader)
            @gl.deleteShader(shader)

        @uniforms = getUniforms(@gl, @program, uniformNames)
        @attribs  = getAttribs(@gl, @program, attribNames)


    use: ->
        @gl.useProgram(@program)


    createShaders = (gl, shaderData) ->
        for [type, source] in shaderData
            shader = gl.createShader(type)

            gl.shaderSource(shader, source)
            gl.compileShader(shader)

            shader # Implicit join & return


    checkShaders = (gl, shaders) ->
        for shader in shaders
            if not gl.getShaderParameter(shader, gl.COMPILE_STATUS)
                log = gl.getShaderInfoLog(shader)

                for shader in shaders
                    gl.deleteShader(shader)

                throw "Shader compilation failed:\n#{log}"


    getUniforms = (gl, program, uniformNames) ->
        uniforms = {}
        for name in uniformNames
            location = gl.getUniformLocation(program, name)
            if location is null
                throw "Failed to locate uniform #{name}"

            uniforms[name] = location
        return uniforms


    getAttribs = (gl, program, attribNames) ->
        attribs = {}
        for name in attribNames
            location = gl.getAttribLocation(program, name)
            if location is -1
                throw "Failed to locate attrib #{name}"

            attribs[name] = location
        return attribs


class Buffer
    ARRAY_BUFFER = 34962
    STATIC_DRAW  = 35044

    constructor: (@gl, data, @type = ARRAY_BUFFER, usage = STATIC_DRAW) ->
        @buffer = @gl.createBuffer()
        @bind()
        @gl.bufferData(@type, data, usage, 0)

    bind: ->
        @gl.bindBuffer(@type, @buffer)
