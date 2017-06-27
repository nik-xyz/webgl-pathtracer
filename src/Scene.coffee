class Scene
    constructor: (@gl, @triangles) ->
        @texSizeLimit = @gl.getParameter(@gl.MAX_TEXTURE_SIZE)

        @floatDataTex = @createTexture(@triangles)
        @floatDataMask = @floatDataTex.width - 1
        @floatDataShift = Math.log2(@floatDataTex.width)


    createTexture: (data) ->
        # Must pad the data to be a power-of-two length
        # so that it can be uploaded to a power-of-two texture
        channels = 3
        size = 1 << Math.ceil(Math.log2(data.length / channels))

        sizeLimit = @texSizeLimit * @texSizeLimit
        if size > sizeLimit
            throw "Required texture size of #{size} exceeds limit of #{sizeLimit}"

        paddedData = new Float32Array(size * channels)
        for value, index in data
            paddedData[index] = value

        width = Math.min(size, @texSizeLimit)
        height = size / width

        return new Texture(
            @gl, width, height, @gl.RGB32F, @gl.RGB, @gl.FLOAT, paddedData)
