/*
    The diffuse reflectivity, specular reflectivity, and emission color
    attributes are determined by a multiplier and optionally a texture.
    If a texture is provided, then the color is determined by
    (multiplier * texture), otherwise it is determined by the multiplier alone.
*/
class Material {
    // Hack: define 'constants' with const getters
    static get NO_IMAGE_ADDRESS() { return -1; }

    constructor() {
        this.specularity = 0.5;
        this.diffuseCoeff  = new Vec3(1.0);
        this.specularCoeff = new Vec3(1.0);
        this.emissionCoeff = new Vec3(0.0);
        this.diffuseImage  = null;
        this.specularImage = null;
        this.emissionImage = null;
    }

    static loadImage(imageSrc) {
        const image = new Image();
        const promise = new Promise((resolve) => {
            image.onload = () => {
                resolve(image);
            };
        });
        image.src = imageSrc;
        return promise;
    }

    async setDiffuseImage(diffuseImageSrc) {
        this.diffuseImage = await Material.loadImage(diffuseImageSrc);
    }

    async setSpecularImage(specularImageSrc) {
        this.specularImage = await Material.loadImage(specularImageSrc);
    }

    async setEmissionImage(emissionImageSrc) {
        this.emissionImage = await Material.loadImage(emissionImageSrc);
    }

    toJSONEncodableObj() {
        const obj = {
            specularity:   this.specularity,
            diffuseCoeff:  this.diffuseCoeff.array(),
            specularCoeff: this.specularCoeff.array(),
            emissionCoeff: this.emissionCoeff.array()
        };

        if (this.diffuseImage) {
            obj.diffuseImage  = this.diffuseImage.src;
        }
        if (this.specularImage) {
            obj.specularImage = this.specularImage.src;
        }
        if (this.emissionImage) {
            obj.emissionImage = this.emissionImage.src;
        }

        return obj;
    }

    static async fromJSONEncodableObj(obj) {
        const requiredKeys = ["specularity", "diffuseCoeff", "specularCoeff", "emissionCoeff"];
        if(!requiredKeys.every(key => key in obj)) {
            throw new Error("Invalid JSON!");
        }

        const material = new Material();
        material.diffuseCoeff  = Vec3.fromJSONEncodableObj(obj.diffuseCoeff).checkNumeric();
        material.specularCoeff = Vec3.fromJSONEncodableObj(obj.specularCoeff).checkNumeric();
        material.emissionCoeff = Vec3.fromJSONEncodableObj(obj.emissionCoeff).checkNumeric();
        material.specularity   = obj.specularity;
        if(!Number.isFinite(material.specularity)) {
            throw new Error("Invalid JSON!");
        }

        if("diffuseImage" in obj) {
            await material.setDiffuseImage(obj.diffuseImage);
        }
        if("specularImage" in obj) {
            await material.setSpecularImage(obj.specularImage);
        }
        if("emissionImage" in obj) {
            await material.setEmissionImage(obj.emissionImage);
        }

        return material;
    }

    encode(existingImagesBaseIndex) {
        const images = [];

        const pushImageIfItExists = (image) => {
            if(!image) {
                return [Material.NO_IMAGE_ADDRESS, 0, 0];
            }

            const imageIndex = existingImagesBaseIndex + images.length;
            images.push(image);

            return [imageIndex, image.width, image.height];
        };

        const encoded = [];
        encoded.push(this.specularity);
        encoded.push(...this.diffuseCoeff.array());
        encoded.push(...this.specularCoeff.array());
        encoded.push(...this.emissionCoeff.array());
        encoded.push(...pushImageIfItExists(this.diffuseImage));
        encoded.push(...pushImageIfItExists(this.specularImage));
        encoded.push(...pushImageIfItExists(this.emissionImage));

        return [encoded, images];
    }
}
