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
        assertJSONHasKeys(obj, ["cameraPosition", "models"]);

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

    bind(program) {
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

        gl.uniform3fv(uniforms.cameraPosition, this.cameraPosition.array());
    }
}
