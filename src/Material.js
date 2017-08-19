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
        this.diffuseMultiplier  = new Vec3(1.0);
        this.specularMultiplier = new Vec3(1.0);
        this.emissionMultiplier = new Vec3(0.0);
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
            specularity:        this.specularity,
            diffuseMultiplier:  this.diffuseMultiplier.array(),
            specularMultiplier: this.specularMultiplier.array(),
            emissionMultiplier: this.emissionMultiplier.array()
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
        // TODO: validate data fully
        const valid =
            ("specularity"        in obj) &&
            ("diffuseMultiplier"  in obj) &&
            ("specularMultiplier" in obj) &&
            ("emissionMultiplier" in obj);

        if(!valid) {
            throw new Error("Invalid JSON!");
        }

        const material = new Material();
        material.specularity = obj.specularity;
        material.diffuseMultiplier  = new Vec3(...obj.diffuseMultiplier);
        material.specularMultiplier = new Vec3(...obj.specularMultiplier);
        material.emissionMultiplier = new Vec3(...obj.emissionMultiplier);

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

        const pushImageIfitExists = (image) => {
            if(!image) {
                return [Material.NO_IMAGE_ADDRESS, 0, 0];
            }

            const imageIndex = existingImagesBaseIndex + images.length;
            images.push(image);

            return [imageIndex, image.width, image.height];
        };

        const encoded = [];
        encoded.push(this.specularity);
        encoded.push(...this.diffuseMultiplier.array());
        encoded.push(...this.specularMultiplier.array());
        encoded.push(...this.emissionMultiplier.array());
        encoded.push(...pushImageIfitExists(this.diffuseImage));
        encoded.push(...pushImageIfitExists(this.specularImage));
        encoded.push(...pushImageIfitExists(this.emissionImage));

        return [encoded, images];
    }
}
