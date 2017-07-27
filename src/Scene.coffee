class Scene
    constructor: (@gl) ->
        @materials = []
        @triangles = []

        # TODO: don't do this in the constructor
        @setCameraPosition(new Vec3(0, 3, -3))
        @addModel(Models.testModelSphere,
            new Material(new Vec3(), 0.2, new Vec3(1, 1, 1), new Vec3(0, 0, 1)))
        @addModel(Models.testModelCube,
            new Material(new Vec3(), 0.0, new Vec3(1, 1, 1), new Vec3(1, 0, 0)))
        @addModel(Models.testModelPlane,
            new Material(new Vec3(), 0.1, new Vec3(1, 1, 1), new Vec3(1, 1, 1)))
        @finalizeSceneData()


    addModel: (model, material) ->
        materialIndex = @materials.length
        @materials.push(material.encode()...)
        @triangles.push(new TriangleLoader(model, materialIndex).triangles...)


    setCameraPosition: (@cameraPosition) ->


    finalizeSceneData: () ->
        octree = new Octree(@triangles)
        @octreeCenter = octree.root.center
        @octreeSize = octree.root.size

        [octreeBuffer, triangleBuffer] = octree.encode()

        if @octreeDataTex?   then @octreeDataTex.destroy()
        if @triangleDataTex? then @triangleDataTex.destroy()
        if @materialDataTex? then @materialDataTex.destroy()

        @octreeDataTex   = new DataTexture(@gl, @gl.UNSIGNED_INT, octreeBuffer)
        @triangleDataTex = new DataTexture(@gl, @gl.FLOAT, triangleBuffer)
        @materialDataTex = new DataTexture(@gl, @gl.FLOAT, @materials)



    bind: (program) ->
        @triangleDataTex.bind(@gl.TEXTURE0)
        @octreeDataTex.bind(@gl.TEXTURE1)
        @materialDataTex.bind(@gl.TEXTURE2)

        uniforms = program.uniforms

        @gl.uniform1i(uniforms["triangleBufferSampler"], 0)
        @gl.uniform2uiv(uniforms["triangleBufferAddrData"],
            @triangleDataTex.dataMaskAndShift)

        @gl.uniform1i(uniforms["octreeBufferSampler"], 1)
        @gl.uniform2uiv(uniforms["octreeBufferAddrData"],
            @octreeDataTex.dataMaskAndShift)

        @gl.uniform1i(uniforms["materialBufferSampler"], 2)
        @gl.uniform2uiv(uniforms["materialBufferAddrData"],
            @materialDataTex.dataMaskAndShift)

        @gl.uniform3fv(uniforms["octreeCubeCenter"], @octreeCenter.array())
        @gl.uniform1f(uniforms["octreeCubeSize"], @octreeSize)

        @gl.uniform3fv(uniforms["cameraPosition"], @cameraPosition.array())
