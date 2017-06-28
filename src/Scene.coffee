class Scene
    constructor: (@gl) ->


    addTriangles: (triangles) ->
        @triangleAddressEnd = 3 * triangles.length
        @octree = new Octree(triangles)
        data = @processTriangles(triangles)
        @triangleDataTex = new DataTexture(@gl, @gl.FLOAT, 3, data)


    processTriangles: (triangles) ->
        data = []
        for triangle in triangles
            data = data.concat(triangle.encode())

        return data
