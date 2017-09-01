class Scene {
    constructor(gl) {
        this.gl = gl;
        this.models = [];
    }

    toJSONEncodableObj() {
        return  {
            cameraPosition: this.cameraPosition.array(),
            models: this.models.map(model => model.toJSONEncodableObj())
        };
    }

    static async fromJSONEncodableObj(gl, obj) {
        if(["cameraPosition", "models"].some(key => !(key in obj))) {
            throw new Error("Invalid JSON!");
        }

        const scene = new Scene(gl);
        scene.cameraPosition = Vec3.fromJSONEncodableObj(obj.cameraPosition).checkNumeric();

        for(const modelObj of obj.models) {
            scene.addModel(await ModelInstance.fromJSONEncodableObj(modelObj));
        }
        return scene;
    }

    addModel(model) {
        this.models.push(model);
    }

    uploadSceneData() {
        const triangles = [];
        const materialData = [];
        const materialImages = [];

        for(const model of this.models) {
            triangles.push(...model.getTriangles(materialData.length));
            materialData.push(...model.material.encode(materialImages));
        }

        this.uploadImages(materialImages);

        const [treeUintBuffer, treeFloatBuffer] = new KDTree(triangles).encode();

        if(this.treeDataTex) {
            this.treeDataTex.destroy();
        }
        if(this.triangleDataTex) {
            this.triangleDataTex.destroy();
        }
        if(this.materialDataTex) {
            this.materialDataTex.destroy();
        }

        this.treeDataTex     = new DataTexture(this.gl, this.gl.UNSIGNED_INT, treeUintBuffer);
        this.triangleDataTex = new DataTexture(this.gl, this.gl.FLOAT, treeFloatBuffer);
        this.materialDataTex = new DataTexture(this.gl, this.gl.FLOAT, materialData);
    }

    uploadImages(images) {
        let size = new Vec2(0);

        for(const image of images) {
            size = size.max(new Vec2(image.width, image.height));
        }

        this.materialTexArray = new ArrayTexture(this.gl, size, images.length, this.gl.RGBA8,
            this.gl.RGBA, this.gl.UNSIGNED_BYTE, images, this.gl.LINEAR);
    }

    bind(program) {
        this.triangleDataTex.bind(this.gl.TEXTURE0);
        this.treeDataTex.bind(this.gl.TEXTURE1);
        this.materialDataTex.bind(this.gl.TEXTURE2);

        this.gl.uniform1i(program.uniforms.treeFloatBufferSampler, 0);
        this.gl.uniform2uiv(program.uniforms.treeFloatBufferAddrData,
            this.triangleDataTex.dataMaskAndShift);

        this.gl.uniform1i(program.uniforms.treeUintBufferSampler, 1);
        this.gl.uniform2uiv(program.uniforms.treeUintBufferAddrData,
            this.treeDataTex.dataMaskAndShift);

        this.gl.uniform1i(program.uniforms.materialBufferSampler, 2);
        this.gl.uniform2uiv(program.uniforms.materialBufferAddrData,
            this.materialDataTex.dataMaskAndShift);

        this.materialTexArray.bind(this.gl.TEXTURE4);
        this.gl.uniform1i(program.uniforms.materialTexArraySampler, 4);

        this.gl.uniform3fv(program.uniforms.cameraPosition, this.cameraPosition.array());
    }
}
