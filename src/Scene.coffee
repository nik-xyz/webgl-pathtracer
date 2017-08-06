class Scene
    constructor: (@gl) ->
        @models = []

        # TODO: Don't do this here. Any of it
        @setCameraPosition(new Vec3(0, 3, -3))

        red   = new Material(new Vec3(), 0.0, new Vec3(1, 1, 1), new Vec3(0.5, 0, 0))
        green = new Material(new Vec3(), 0.2, new Vec3(1, 1, 1), new Vec3(0, 0.35, 0.1))
        blue  = new Material(new Vec3(), 0.2, new Vec3(1, 1, 1), new Vec3(0, 0, 0.5))
        white = new Material(new Vec3(), 0.1, new Vec3(0.2, 0.2, 0.2), new Vec3(0.5, 0.5, 0.5))
        yellow = new Material(new Vec3(5, 4, 0.0), 0.1, new Vec3(1, 1, 1), new Vec3(1, 0.6, 0.0))

        sphere = new Model(Models.testModelSphere)
        cube   = new Model(Models.testModelCube)
        cube2  = new Model(Models.testModelCube)
        cube3  = new Model(Models.testModelCube)
        plane  = new Model(Models.testModelPlane)

        plane.setPosition(new Vec3(0, -1.5, 0))
        cube.setPosition(new Vec3(1.5, -0.5, -0.8))
        cube2.setPosition(new Vec3(-1.5, -1, 0.8))
        cube3.setPosition(new Vec3(-1.5, -1, -1.3))
        cube3.setSize(new Vec3(0.4, 0.4, 0.4))

        @addModel(sphere, green)
        @addModel(cube,   red)
        @addModel(cube2,  blue)
        @addModel(cube3,  yellow)
        @addModel(plane,  white)

        image = new Image()
        image.src = testImage
        image.onload = =>
            @testTex = new Texture(@gl, new Vec2(512, 256), @gl.RGBA8, @gl.RGBA,
                @gl.UNSIGNED_BYTE, image, @gl.LINEAR)

        @uploadSceneData()


    addModel: (model, material) ->
        @models.push([model, material])


    setCameraPosition: (@cameraPosition) ->


    uploadSceneData: () ->
        triangles = []
        materialData = []
        materialCounter = 0

        for [model, material] in @models
            triangles.push(model.getTriangles(materialData.length)...)
            materialData.push(material.encode()...)

        [treeUintBuffer, treeFloatBuffer] = new KDTree(triangles).encode()

        if @treeDataTex?     then @treeDataTex.destroy()
        if @triangleDataTex? then @triangleDataTex.destroy()
        if @materialDataTex? then @materialDataTex.destroy()

        @treeDataTex     = new DataTexture(@gl, @gl.UNSIGNED_INT, treeUintBuffer)
        @triangleDataTex = new DataTexture(@gl, @gl.FLOAT, treeFloatBuffer)
        @materialDataTex = new DataTexture(@gl, @gl.FLOAT, materialData)


    bind: (program) ->
        @triangleDataTex.bind(@gl.TEXTURE0)
        @treeDataTex.bind(@gl.TEXTURE1)
        @materialDataTex.bind(@gl.TEXTURE2)

        uniforms = program.uniforms

        @gl.uniform1i(uniforms["treeFloatBufferSampler"], 0)
        @gl.uniform2uiv(uniforms["treeFloatBufferAddrData"],
            @triangleDataTex.dataMaskAndShift)

        @gl.uniform1i(uniforms["treeUintBufferSampler"], 1)
        @gl.uniform2uiv(uniforms["treeUintBufferAddrData"],
            @treeDataTex.dataMaskAndShift)

        @gl.uniform1i(uniforms["materialBufferSampler"], 2)
        @gl.uniform2uiv(uniforms["materialBufferAddrData"],
            @materialDataTex.dataMaskAndShift)

        @testTex.bind(@gl.TEXTURE4)
        @gl.uniform1i(uniforms["testImageSampler"], 4)

        @gl.uniform3fv(uniforms["cameraPosition"], @cameraPosition.array())
