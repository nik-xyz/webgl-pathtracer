class Scene
    constructor: (@gl) ->
        triangles = new TriangleLoader(Models.testModel).triangles

        @octree = new Octree(triangles)
        [octreeBuffer, triangleBuffer] = @octree.encode()

        @octreeDataTex   = new DataTexture(@gl, @gl.UNSIGNED_INT, octreeBuffer)
        @triangleDataTex = new DataTexture(@gl, @gl.FLOAT, triangleBuffer)

        @cameraPosition = new Vec3(0, 3, -3)


    uploadData: (program) ->
        @triangleDataTex.bind(@gl.TEXTURE0)
        @octreeDataTex.bind(@gl.TEXTURE1)

        uniforms = program.uniforms

        @gl.uniform1i( uniforms["triangleBufferSampler"], 0)
        @gl.uniform1ui(uniforms["triangleBufferMask"],  @triangleDataTex.dataMask)
        @gl.uniform1ui(uniforms["triangleBufferShift"], @triangleDataTex.dataShift)

        @gl.uniform1i( uniforms["octreeBufferSampler"], 1)
        @gl.uniform1ui(uniforms["octreeBufferMask"],  @octreeDataTex.dataMask)
        @gl.uniform1ui(uniforms["octreeBufferShift"], @octreeDataTex.dataShift)

        @gl.uniform3fv(uniforms["octreeCubeCenter"], @octree.root.center.array())
        @gl.uniform1f( uniforms["octreeCubeSize"],   @octree.root.size)

        @gl.uniform3fv(uniforms["cameraPosition"], @cameraPosition.array())
