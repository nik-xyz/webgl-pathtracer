class Scene {
    constructor(gl) {
        this.gl = gl;
        this.models = [];
    }


    toJSONEncodableObj() {
        var models = [];

        for(var [model, material] of this.models) {
            models.push({
                model:    model.toJSONEncodableObj(),
                material: material.toJSONEncodableObj()
            });
        }

        return  {
            cameraPosition: this.cameraPosition.array(),
            models: models
        };
    }


    static fromJSONEncodableObj(gl, obj) {
        // TODO: validate data fully

        if(!("cameraPosition" in obj) || !("models" in obj)) {
            throw new Error("Invalid JSON!");
        }

        var scene = new Scene(gl);
        scene.cameraPosition = new Vec3(...obj.cameraPosition);

        for(var modelObj of obj.models) {
            if(!("model" in modelObj) || !("material" in modelObj)) {
                throw new Error("Invalid JSON!");
            }

            var model    = Model.fromJSONEncodableObj(modelObj.model);
            var material = Material.fromJSONEncodableObj(modelObj.material);

            scene.addModel(model, material);
        }
        return scene;
    }


    addModel(model, material) {
        this.models.push([model, material]);
    }


    uploadSceneData() {
        var triangles = [];
        var materialData = [];
        var materialImages = [];

        for(var [model, material] of this.models) {
            triangles.push(...model.getTriangles(materialData.length));

            var [data, images] = material.encode(materialImages.length);
            materialData.push(...data);
            materialImages.push(...images);
        }

        this.uploadImages(materialImages);

        var [treeUintBuffer, treeFloatBuffer] = new KDTree(triangles).encode();


        /*if(this.treeDataTex !== null) {
            this.treeDataTex.destroy();
        }
        if(this.triangleDataTex !== null) {
            this.triangleDataTex.destroy();
        }
        if(this.materialDataTex !== null) {
            this.materialDataTex.destroy();
        }*/

        this.treeDataTex     = new DataTexture(this.gl, this.gl.UNSIGNED_INT, treeUintBuffer);
        this.triangleDataTex = new DataTexture(this.gl, this.gl.FLOAT, treeFloatBuffer);
        this.materialDataTex = new DataTexture(this.gl, this.gl.FLOAT, materialData);
    }

    uploadImages(images) {
        // TODO: restructure

        var size = new Vec2(0);

        for(var image of images) {
            size = size.max(new Vec2(image.width, image.height));
        }

        this.materialTexArray = new ArrayTexture(
            this.gl, size, images.length, this.gl.RGBA8, this.gl.RGBA,
            this.gl.UNSIGNED_BYTE, images, this.gl.LINEAR);
    }


    bind(program) {
        this.triangleDataTex.bind(this.gl.TEXTURE0);
        this.treeDataTex.bind(this.gl.TEXTURE1);
        this.materialDataTex.bind(this.gl.TEXTURE2);

        this.gl.uniform1i(program.uniforms["treeFloatBufferSampler"], 0);
        this.gl.uniform2uiv(program.uniforms["treeFloatBufferAddrData"],
            this.triangleDataTex.dataMaskAndShift);

        this.gl.uniform1i(program.uniforms["treeUintBufferSampler"], 1);
        this.gl.uniform2uiv(program.uniforms["treeUintBufferAddrData"],
            this.treeDataTex.dataMaskAndShift);

        this.gl.uniform1i(program.uniforms["materialBufferSampler"], 2);
        this.gl.uniform2uiv(program.uniforms["materialBufferAddrData"],
            this.materialDataTex.dataMaskAndShift);

        // TODO: check that the materialTexArray exists and handle appropriately
        this.materialTexArray.bind(this.gl.TEXTURE4);
        this.gl.uniform1i(program.uniforms["materialTexArraySampler"], 4);

        this.gl.uniform3fv(program.uniforms["cameraPosition"],
            this.cameraPosition.array());
    }
}
