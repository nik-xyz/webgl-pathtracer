// Represents an element of material that can either be a constant value or a texture
class MaterialComponent {
    static async fromJSONEncodableObj(obj) {
        assertJSONHasKeys(obj, ["flat", "value"]);

        const component = new MaterialComponent();
        if(obj.flat) {
            component.setFlat(Vec3.fromJSONEncodableObj(obj.value));
        }
        else {
            await component.setImage(obj.value);
        }
        return component;
    }

    toJSONEncodableObj() {
        return {
            flat:  this.isFlat,
            value: this.isFlat ? this.value.array() : this.value.src
        };
    }

    setFlat(flat) {
        this.isFlat = true;
        this.value = flat;
    }

    async setImage(imageSrc) {
        this.isFlat = false;

        this.value = new Image();
        await new Promise((resolve) => {
            this.value.onload = resolve;
            this.value.src = imageSrc;
        });
    }

    encode(imageStack) {
        if(this.isFlat) {
            return this.value.array();
        }
        else {
            const imageData = [imageStack.length, this.value.width, this.value.height];
            imageStack.push(this.value);
            return imageData;
        }
    }
}

class Material {
    static async fromJSONEncodableObj(obj) {
        assertJSONHasKeys(obj, ["specularity", "diffuse", "specular", "emission"]);

        if(!Number.isFinite(obj.specularity)) {
            throw new Error("Invalid JSON!");
        }

        const material = new Material();
        material.specularity = obj.specularity;
        material.diffuse  = await MaterialComponent.fromJSONEncodableObj(obj.diffuse);
        material.specular = await MaterialComponent.fromJSONEncodableObj(obj.specular);
        material.emission = await MaterialComponent.fromJSONEncodableObj(obj.emission);

        return material;
    }

    toJSONEncodableObj() {
        return {
            specularity: this.specularity,
            diffuse:     this.diffuse.toJSONEncodableObj(),
            specular:    this.specular.toJSONEncodableObj(),
            emission:    this.emission.toJSONEncodableObj()
        };
    }

    static get DEFAULT_MATERIAL_JSON() {
        return {
            specularity: 0.5,
            diffuse:  { flat: true, value: [1.0, 1.0, 1.0] },
            specular: { flat: true, value: [1.0, 1.0, 1.0] },
            emission: { flat: true, value: [0.0, 0.0, 0.0] },
        }
    }

    // Encodes the material into an array using the same format as struct Material
    // in Material.glsl. Also pushes images onto the stack that is provided.
    encode(imageStack) {
        const encoded = [];
        encoded.push(this.specularity);

        const components = [this.diffuse, this.specular, this.emission];

        // Construct and push bitfeild that determines which components use textures
        const bitForComponent = (component, bit) => (component.isFlat ? 0 : 1) << bit;
        encoded.push(components.map(bitForComponent).reduce((a, b) => a | b));

        for(const component of components) {
            encoded.push(...component.encode(imageStack));
        }

        return encoded;
    }
}
