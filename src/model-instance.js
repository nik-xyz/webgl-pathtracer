class ModelInstance {
    // Hack: define 'constants' with getters
    static get DEFAULT_POSITION() { return new Vec3(0); }
    static get DEFAULT_ROTATION() { return new Vec3(0); }
    static get DEFAULT_SIZE()     { return new Vec3(1); }

    static async fromJSON(obj) {
        assertJSONHasKeys(obj, ["name", "model", "material", "position", "size", "rotation"]);

        const model    = new ModelInstance();
        model.name     = obj.name;
        model.model    = Model.fromJSON(obj.model);
        model.material = await Material.fromJSON(obj.material);
        model.position = Vec3.fromJSON(obj.position).checkNumeric();
        model.rotation = Vec3.fromJSON(obj.rotation).checkNumeric();
        model.size     = Vec3.fromJSON(obj.size).checkNumeric();

        return model;
    }

    toJSON() {
        return {
            name:     this.name,
            model:    this.model.toJSON(),
            material: this.material.toJSON(),
            position: this.position.array(),
            rotation: this.rotation.array(),
            size:     this.size.array()
        };
    }

    getTriangles(materialIndex) {
        const transforms = {
            pos: vec => vec.mul(this.size).rotateEuler(this.rotation, true).add(this.position),
            nor: vec => vec,
            tex: vec => vec
        };

        return this.model.getTriangles(transforms, materialIndex);
    }
}
