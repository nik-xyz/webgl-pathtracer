class Scene
    constructor: (@gl) ->


    addTriangles: (triangles) ->
        @triangleAddressEnd = 3 * triangles.length
        data = @processTriangles(triangles)
        @triangleDataTex = new DataTexture(@gl, @gl.FLOAT, 3, data)


    processTriangles: (triangles) ->
        data = []
        for triangle in triangles
            # TODO: use better method of appending here
            data = data.concat(triangle.encode())

        return data
