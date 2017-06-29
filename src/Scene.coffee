class Scene
    constructor: (@gl, triangles) ->
        @octree = new Octree(triangles)
        [octreeBuffer, triangleBuffer] = @octree.encode()

        @octreeDataTex   = new DataTexture(@gl, @gl.UNSIGNED_INT, 1, octreeBuffer)
        @triangleDataTex = new DataTexture(@gl, @gl.FLOAT, 3, triangleBuffer)
        
