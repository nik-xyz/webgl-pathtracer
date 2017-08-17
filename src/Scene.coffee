class Scene
    constructor: (@gl) ->
        @models = []


    toJSONEncodableObj: () ->
        sceneObj = {}

        sceneObj.cameraPosition = @cameraPosition.array()

        sceneObj.models = []

        for [model, material] in @models
            modelObj = {}
            modelObj.model    = model.toJSONEncodableObj()
            modelObj.material = material.toJSONEncodableObj()

            sceneObj.models.push(modelObj)

        sceneObj


    @fromJSONEncodableObj: (gl, obj) ->
        unless obj.cameraPosition? and obj.models?
            throw "Invalid JSON!"

        # TODO: validate data fully

        scene = new Scene(gl)
        `scene.cameraPosition = new Vec3(...obj.cameraPosition);`

        for modelObj in obj.models
            unless modelObj.model? and modelObj.material?
                throw "Invalid JSON!"

            model    = Model.fromJSONEncodableObj(modelObj.model)
            material = Material.fromJSONEncodableObj(modelObj.material)

            scene.addModel(model, material)
        scene


    addModel: (model, material) ->
        @models.push([model, material])


    # TODO: move this somewhere else because storing the camera position
    # doesn't fit the role of the scene class
    setCameraPosition: (@cameraPosition) ->


    uploadSceneData: () ->
        triangles = []
        materialData = []
        materialImages = []

        for [model, material] in @models
            triangles.push(model.getTriangles(materialData.length)...)

            [data, images] = material.encode(materialImages.length)
            materialData.push(data...)
            materialImages.push(images...)

        @uploadImages(materialImages)

        [treeUintBuffer, treeFloatBuffer] = new KDTree(triangles).encode()

        if @treeDataTex?     then @treeDataTex.destroy()
        if @triangleDataTex? then @triangleDataTex.destroy()
        if @materialDataTex? then @materialDataTex.destroy()

        @treeDataTex     = new DataTexture(@gl, @gl.UNSIGNED_INT, treeUintBuffer)
        @triangleDataTex = new DataTexture(@gl, @gl.FLOAT, treeFloatBuffer)
        @materialDataTex = new DataTexture(@gl, @gl.FLOAT, materialData)


    uploadImages: (images) ->
        # TODO: restructure

        `size = new Vec2(0)`

        for image in images
            `size = size.max(new Vec2(image.width, image.height))`

        @materialTexArray = new ArrayTexture(
            @gl, size, images.length, @gl.RGBA8, @gl.RGBA, @gl.UNSIGNED_BYTE,
            images, @gl.LINEAR)



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

        # TODO: check that the materialTexArray exists and handle appropriately
        @materialTexArray.bind(@gl.TEXTURE4)
        @gl.uniform1i(uniforms["materialTexArraySampler"], 4)

        @gl.uniform3fv(uniforms["cameraPosition"], @cameraPosition.array())
