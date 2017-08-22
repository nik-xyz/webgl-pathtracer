class ModelInstance {
    // Hack: define 'constants' with getters
    static get DEFAULT_POSITION() { return new Vec3(0); }
    static get DEFAULT_SIZE()     { return new Vec3(1); }

    constructor(model, position = Model.DEFAULT_POSITION, size = Model.DEFAULT_SIZE) {
        this.model    = model;
        this.position = position;
        this.size     = size;
    }

    toJSONEncodableObj() {
        return {
            data:     this.model.toJSONEncodableObj(),
            position: this.position.array(),
            size:     this.size.array()
        };
    }

    static fromJSONEncodableObj(obj) {
        if(["data", "position", "size"].every(key => key in obj)) {
            return new ModelInstance(
                Model.fromJSONEncodableObj(obj.data),
                Vec3.fromJSONEncodableObj(obj.position).checkNumeric(),
                Vec3.fromJSONEncodableObj(obj.size).checkNumeric()
            );
        }
        throw new Error("invalid JSON");
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
