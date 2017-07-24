class Scene
    constructor: (@gl) ->
        trianglesSphere = new TriangleLoader(Models.testModelSphere, 0).triangles
        trianglesCube = new TriangleLoader(Models.testModelCube, 1).triangles
        trianglesPlane = new TriangleLoader(Models.testModelPlane, 2).triangles
        triangles = trianglesSphere.concat(trianglesCube).concat(trianglesPlane)

        octree = new Octree(triangles)

        @octreeCenter = octree.root.center
        @octreeSize = octree.root.size

        [octreeBuffer, triangleBuffer] = octree.encode()
        @octreeDataTex = new DataTexture(@gl, @gl.UNSIGNED_INT, octreeBuffer)
        @triangleDataTex = new DataTexture(@gl, @gl.FLOAT, triangleBuffer)

        @cameraPosition = new Vec3(0, 3, -3)


    uploadData: (program) ->
        @triangleDataTex.bind(@gl.TEXTURE0)
        @octreeDataTex.bind(@gl.TEXTURE1)

        uniforms = program.uniforms

        @gl.uniform1i(uniforms["triangleBufferSampler"], 0)
        @gl.uniform2uiv(uniforms["triangleBufferAddrData"],
            @triangleDataTex.dataMaskAndShift)

        @gl.uniform1i(uniforms["octreeBufferSampler"], 1)
        @gl.uniform2uiv(uniforms["octreeBufferAddrData"],
            @octreeDataTex.dataMaskAndShift)

        @gl.uniform3fv(uniforms["octreeCubeCenter"], @octreeCenter.array())
        @gl.uniform1f(uniforms["octreeCubeSize"], @octreeSize)

        @gl.uniform3fv(uniforms["cameraPosition"], @cameraPosition.array())
