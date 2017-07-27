class ShaderProgram
    constructor: (@gl, shaderData, uniformNames = [], attribNames = [],
        uniformsReqired = false
    ) ->
        shaders = createShaders(@gl, shaderData)
        checkShaders(@gl, shaders)

        @program = @gl.createProgram()

        for shader in shaders
            @gl.attachShader(@program, shader)

        @gl.linkProgram(@program)

        for shader in shaders
            @gl.detachShader(@program, shader)
            @gl.deleteShader(shader)

        @uniforms = getUniforms(@gl, @program, uniformNames, uniformsReqired)
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
            unless gl.getShaderParameter(shader, gl.COMPILE_STATUS)
                log = gl.getShaderInfoLog(shader)

                for shader in shaders
                    gl.deleteShader(shader)

                throw "Shader compilation failed:\n#{log}"


    getUniforms = (gl, program, uniformNames, required) ->
        uniforms = {}
        for name in uniformNames
            location = gl.getUniformLocation(program, name)
            if location is null
                message = "Failed to locate uniform #{name}"
                if required
                    throw message
                else
                    console.error(message)

            uniforms[name] = location
        uniforms


    getAttribs = (gl, program, attribNames) ->
        attribs = {}
        for name in attribNames
            location = gl.getAttribLocation(program, name)
            if location is -1
                throw "Failed to locate attrib #{name}"

            attribs[name] = location
        attribs


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


    destroy: ->
        @gl.deleteTexture(@tex)


class DataTexture extends Texture
    constructor: (@gl, type, data) ->
        # Find the appropriate typed arrays and image formats for the data
        [arrayType, internalFormat, format] =
            if type is @gl.FLOAT
                [Float32Array, @gl.R32F, @gl.RED]

            else if type is @gl.UNSIGNED_INT
                [Uint32Array, @gl.R32UI, @gl.RED_INTEGER]

            else
                throw "Data type not supported"

        # Must pad the data to be a power-of-two length
        # so that it can be uploaded to a power-of-two texture
        paddedSize = Math.pow(2, Math.ceil(Math.log2(data.length)))

        # Check data fits inside texture size limits
        sizeLimit = @gl.getParameter(@gl.MAX_TEXTURE_SIZE)
        sizeLimitSq = @texSizeLimit * @texSizeLimit
        if paddedSize > sizeLimitSq
            throw "Required texture size exceeds limit"

        # Avoid copying if the original array meets the necessary requirements
        unless (data instanceof arrayType) and (data.length is paddedSize)
            paddedData = new arrayType(paddedSize)
            paddedData.set(data)
            data = paddedData

        # Choose width and height so that the texture is large enough
        # to store the data while staying inside the size limits
        width = Math.min(paddedSize, sizeLimit)
        height = paddedSize / Math.max(width, 1)

        # Calculate address mask and shift values to allow
        # the texture to be accessed with a 1D index
        @dataMaskAndShift = [width - 1, Math.log2(width)]

        # Create texture
        super(@gl, width, height, internalFormat, format, type, data)


class VertexArray
    constructor: (@gl) ->
        @vao = @gl.createVertexArray()


    setupAttrib: (location, buffer, size, type, stride = 0, offset = 0) ->
        @bind()
        buffer.bind()
        @gl.enableVertexAttribArray(location)
        @gl.vertexAttribPointer(location, size, type, false, stride, offset)


    bind: ->
        @gl.bindVertexArray(@vao)


class TexFramebuffer
    constructor: (@gl, @resolution) ->
        floatExt = @gl.getExtension("EXT_color_buffer_float")
        internalFormat = if floatExt then @gl.RGBA32F else @gl.RGBA8

        @buf = @gl.createFramebuffer()
        @gl.bindFramebuffer(@gl.FRAMEBUFFER, @buf)

        @rb = @gl.createRenderbuffer()
        @gl.bindRenderbuffer(@gl.RENDERBUFFER, @rb)

        @gl.renderbufferStorage(@gl.RENDERBUFFER, internalFormat,
            @resolution.x, @resolution.y);

        @gl.framebufferRenderbuffer(@gl.FRAMEBUFFER, @gl.COLOR_ATTACHMENT0,
            @gl.RENDERBUFFER, @rb);

        @gl.bindRenderbuffer(@gl.RENDERBUFFER, null)
        @gl.bindFramebuffer(@gl.FRAMEBUFFER, null)


    destroy: ->
        @gl.destroyFramebuffer(@buf)
        @gl.destroyRenderbuffer(@rb)
