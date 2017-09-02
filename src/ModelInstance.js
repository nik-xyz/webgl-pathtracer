class ModelInstance {
    // Hack: define 'constants' with getters
    static get DEFAULT_POSITION() { return new Vec3(0); }
    static get DEFAULT_SIZE()     { return new Vec3(1); }

    static async fromJSONEncodableObj(obj) {
        assertJSONHasKeys(obj, ["name", "model", "material", "position", "size"]);

        const model = new ModelInstance();
        model.name     = obj.name;
        model.model    = Model.fromJSONEncodableObj(obj.model);
        model.material = await Material.fromJSONEncodableObj(obj.material);
        model.position = Vec3.fromJSONEncodableObj(obj.position).checkNumeric();
        model.size     = Vec3.fromJSONEncodableObj(obj.size).checkNumeric();

        return model;
    }

    toJSONEncodableObj() {
        return {
            name:     this.name,
            model:    this.model.toJSONEncodableObj(),
            material: this.material.toJSONEncodableObj(),
            position: this.position.array(),
            size:     this.size.array()
        };
    }

    getTriangles(materialIndex) {
        const transforms = {
            pos: vec => vec.mul(this.size).add(this.position),
            nor: vec => vec,
            tex: vec => vec
        };

        return this.model.getTriangles(transforms, materialIndex);
    }
}
