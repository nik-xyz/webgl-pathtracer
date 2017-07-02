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


class Texture
    constructor: (@gl, @width, @height, internalFormat, format, type, data) ->
        @tex = @gl.createTexture()
        @gl.bindTexture(@gl.TEXTURE_2D, @tex)
        @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MIN_FILTER, @gl.NEAREST)
        @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MAG_FILTER, @gl.NEAREST)
        @gl.texImage2D(@gl.TEXTURE_2D, 0, internalFormat,
            @width, @height, 0, format, type, data)


    bind: (unit) ->
        @gl.activeTexture(unit)
        @gl.bindTexture(@gl.TEXTURE_2D, @tex)


class DataTexture extends Texture
    constructor: (@gl, type, data) ->
        if type not in [@gl.FLOAT, @gl.UNSIGNED_INT]
            throw "Data type not supported"

        # Must pad the data to be a power-of-two length
        # so that it can be uploaded to a power-of-two texture
        paddedSize = Math.pow(2, Math.ceil(Math.log2(data.length)))

        # Check data fits inside texture size limits
        sizeLimit = @gl.getParameter(@gl.MAX_TEXTURE_SIZE)
        sizeLimitSq = @texSizeLimit * @texSizeLimit
        if paddedSize > sizeLimitSq
            throw "Required texture size of #{paddedSize} exceeds limit of #{sizeLimitSq}"

        arrayType = if type is @gl.FLOAT then Float32Array else Uint32Array
        paddedData = new arrayType(paddedSize)
        paddedData.set(data)

        # Choose width & height so that the texture is large enough to
        # store the data while staying inside the size limits
        width = Math.min(paddedSize, sizeLimit)
        height = if (width is 0) then 0 else (paddedSize / width)

        # Calculate address mask and shift values to allow
        # the texture to be accessed with a 1D index
        @dataMask  = width - 1
        @dataShift = Math.log2(width)

        super(@gl, width, height, getFormats(@gl, type)..., type, paddedData)


    getFormats = (gl, type) ->
        if type is gl.FLOAT
            return [gl.R32F, gl.RED]
        else
            return [gl.R32UI, gl.RED_INTEGER]



class VertexArray
    constructor: (@gl) ->
        @vao = @gl.createVertexArray()


    setupAttrib: (location, buffer, size, type, stride, offset) ->
        @bind()
        buffer.bind()
        @gl.enableVertexAttribArray(location)
        @gl.vertexAttribPointer(location, size, type, false, stride, offset)


    bind: ->
        @gl.bindVertexArray(@vao)
