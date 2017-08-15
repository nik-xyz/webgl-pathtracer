class Scene
    constructor: (@gl) ->
        @models = []


    setupTestScene: ->
        # TODO: Don't do this here. Any of it
        @setCameraPosition(new Vec3(0, 3, -3))

        red   = new Material()
        green = new Material()
        blue  = new Material()
        white = new Material()
        yellow = new Material()

        yellow.setEmissionMultiplier(new Vec3(5, 4, 0.0))
        white.setSpecularMultiplier(new Vec3(0.2, 0.2, 0.2))

        red.setSpecularity(0.0)
        green.setSpecularity(0.2)
        blue.setSpecularity(0.2)
        white.setSpecularity(0.1)
        yellow.setSpecularity(0.1)

        red.setDiffuseMultiplier(new Vec3(0.5, 0, 0))
        green.setDiffuseMultiplier(new Vec3(1))
        blue.setDiffuseMultiplier(new Vec3(0, 0, 0.5))
        white.setDiffuseMultiplier(new Vec3(0.5, 0.5, 0.5))
        yellow.setDiffuseMultiplier(new Vec3(1, 0.6, 0.0))

        green.setDiffuseImage(testImage0)
        white.setDiffuseImage(testImage1)

        sphere = new Model(Models.testModelSphere)
        cube   = new Model(Models.testModelCube)
        cube2  = new Model(Models.testModelCube)
        cube3  = new Model(Models.testModelCube)
        plane  = new Model(Models.testModelPlane)

        plane.position = new Vec3(0, -1.5, 0)
        cube.position  = new Vec3(1.5, -0.5, -0.8)
        cube2.position = new Vec3(-1.5, -1, 0.8)
        cube3.position = new Vec3(-1.5, -1, -1.3)
        cube3.size     = new Vec3(0.4, 0.4, 0.4)

        @addModel(sphere, green)
        @addModel(cube,   red)
        @addModel(cube2,  blue)
        @addModel(cube3,  yellow)
        @addModel(plane,  white)


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
        scene.cameraPosition = new Vec3(obj.cameraPosition...)

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
        materialCounter = 0

        images = []

        for [model, material] in @models
            triangles.push(model.getTriangles(materialData.length)...)
            materialData.push(material.encode(images)...)

        @uploadImages(images)

        [treeUintBuffer, treeFloatBuffer] = new KDTree(triangles).encode()

        if @treeDataTex?     then @treeDataTex.destroy()
        if @triangleDataTex? then @triangleDataTex.destroy()
        if @materialDataTex? then @materialDataTex.destroy()

        @treeDataTex     = new DataTexture(@gl, @gl.UNSIGNED_INT, treeUintBuffer)
        @triangleDataTex = new DataTexture(@gl, @gl.FLOAT, treeFloatBuffer)
        @materialDataTex = new DataTexture(@gl, @gl.FLOAT, materialData)


    uploadImages: (images) ->
        console.log(images)


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

        #@materialTexArray.bind(@gl.TEXTURE4)
        #@gl.uniform1i(uniforms["materialTexArraySampler"], 4)

        @gl.uniform3fv(uniforms["cameraPosition"], @cameraPosition.array())
