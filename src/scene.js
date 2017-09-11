class Scene {
    static async fromJSON(gl, json) {
        assertJSONHasKeys(json, ["camera", "models"]);

        const scene = new Scene();
        scene.gl = gl;
        scene.models = [];

        scene.camera = Camera.fromJSON(json.camera);
        for(const modelObj of json.models) {
            scene.addModel(await ModelInstance.fromJSON(modelObj));
        }

        return scene;
    }

    toJSON() {
        return {
            camera: this.camera.toJSON(),
            models: this.models.map(model => model.toJSON())
        };
    }

    addModel(model) {
        this.models.push(model);
    }

    addModelAtStart(model) {
        this.models.unshift(model);
    }

    removeModel(model) {
        this.models.splice(this.models.indexOf(model), 1);
    }

    releaseSceneDate() {
        const resources = [
            this.treeDataTex,
            this.triangleDataTex,
            this.materialDataTex,
            this.materialTexArray
        ];

        for(const resource of resources) {
            if(resource) {
                resource.destroy();
            }
        }

        this.treeDataTex      = null;
        this.triangleDataTex  = null;
        this.materialDataTex  = null;
        this.materialTexArray = null;
    }

    uploadSceneData() {
        this.releaseSceneDate();

        const triangles = [];
        const materialData = [];
        const materialImages = [];

        for(const model of this.models) {
            triangles.push(...model.getTriangles(materialData.length));
            materialData.push(...model.material.encode(materialImages));
        }

        if(materialImages.length > 0) {
            const size = materialImages
                .map(image => new Vec2(image.width, image.height))
                .reduce((a, b) => a.max(b));

            this.materialTexArray = new ArrayTexture(
                this.gl, size, materialImages.length, this.gl.RGBA8,
                this.gl.RGBA, this.gl.UNSIGNED_BYTE, materialImages, this.gl.LINEAR
            );
        }

        const [treeUintBuffer, treeFloatBuffer] = new KDTree(triangles).encode();
        this.treeDataTex     = new DataTexture(this.gl, this.gl.UNSIGNED_INT, treeUintBuffer);
        this.triangleDataTex = new DataTexture(this.gl, this.gl.FLOAT, treeFloatBuffer);
        this.materialDataTex = new DataTexture(this.gl, this.gl.FLOAT, materialData);
    }

    bindSceneData(program) {
        const gl = this.gl;
        const uniforms = program.uniforms;

        this.triangleDataTex.bind(gl.TEXTURE0);
        this.treeDataTex    .bind(gl.TEXTURE1);
        this.materialDataTex.bind(gl.TEXTURE2);

        gl.uniform1i(uniforms.treeFloatBufferSampler, 0);
        gl.uniform2uiv(uniforms.treeFloatBufferAddrData, this.triangleDataTex.dataMaskAndShift);

        gl.uniform1i(uniforms.treeUintBufferSampler, 1);
        gl.uniform2uiv(uniforms.treeUintBufferAddrData, this.treeDataTex.dataMaskAndShift);

        gl.uniform1i(uniforms.materialBufferSampler, 2);
        gl.uniform2uiv(uniforms.materialBufferAddrData, this.materialDataTex.dataMaskAndShift);

        if(this.materialTexArray) {
            this.materialTexArray.bind(gl.TEXTURE4);
            gl.uniform1i(uniforms.materialTexArraySampler, 4);
        }
    }
}
