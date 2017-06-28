class Scene
    constructor: (@gl) ->
        @texSizeLimit = @gl.getParameter(@gl.MAX_TEXTURE_SIZE)


    addTriangles: (triangles) ->
        @createTexture(@processTriangles(triangles))
        @triangleAddressEnd = 3 * triangles.length


    processTriangles: (triangles) ->
        data = []
        for triangle in triangles
            # TODO: use better method of appending here
            data = data.concat(triangle.encode())

        return data


    createTexture: (data) ->
        # Must pad the data to be a power-of-two length
        # so that it can be uploaded to a power-of-two texture
        channels = 3
        size = 1 << Math.ceil(Math.log2(data.length / channels))

        sizeLimit = @texSizeLimit * @texSizeLimit
        if size > sizeLimit
            throw "Required texture size of #{size} exceeds limit of #{sizeLimit}"

        paddedData = new Float32Array(size * channels)
        paddedData.set(data)

        width = Math.min(size, @texSizeLimit)
        height = size / width

        @floatDataTex = new Texture(
            @gl, width, height, @gl.RGB32F, @gl.RGB, @gl.FLOAT, paddedData)

        @floatDataMask = @floatDataTex.width - 1
        @floatDataShift = Math.log2(@floatDataTex.width)
