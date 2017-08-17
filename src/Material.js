/*
    The diffuse reflectivity, specular reflectivity, and emission color
    attributes are determined by a multiplier and optionally a texture.
    If a texture is provided, then the color is determined by
    (multiplier * texture), otherwise it is determined by the multiplier alone.
*/
class Material {
    constructor() {
        // Value that is used to indicate that a material component has no
        // associated texture
        this.NO_IMAGE_ADDRESS = -1

        this.specularity = 0.5;
        this.diffuseMultiplier  = new Vec3(1.0);
        this.specularMultiplier = new Vec3(1.0);
        this.emissionMultiplier = new Vec3(0.0);
        this.diffuseImage  = null;
        this.specularImage = null;
        this.emissionImage = null;
    }


    // TODO: wait for these promises to resolve before doing anything with the images
    // Right now, chromium requires the page to be at least once reloaded before it
    // will work
    setDiffuseImage(diffuseImageSrc) {
        this.diffuseImage = new Image();
        const loadedPromise = new Promise((resolve) => this.diffuseImage.onload = resolve);
        this.diffuseImage.src = diffuseImageSrc;
        return loadedPromise;
    }


    setSpecularImage(specularImageSrc) {
        this.specularImage = new Image();
        const loadedPromise = new Promise((resolve) => this.specularImage.onload = resolve);
        this.specularImage.src = specularImageSrc;
        return loadedPromise;
    }


    setEmissionImage(emissionImageSrc) {
        this.emissionImage = new Image();
        const loadedPromise = new Promise((resolve) => this.emissionImage.onload = resolve);
        this.emissionImage.src = emissionImageSrc;
        return loadedPromise;
    }



    toJSONEncodableObj() {
        var obj = {
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


    static fromJSONEncodableObj(obj) {
        // TODO: restructure & validate data fully
        var valid = true;
        valid = valid && (typeof obj.specularity        !== undefined);
        valid = valid && (typeof obj.diffuseMultiplier  !== undefined);
        valid = valid && (typeof obj.specularMultiplier !== undefined);
        valid = valid && (typeof obj.emissionMultiplier !== undefined);

        if(!valid) {
            throw new Error("Invalid JSON!");
        }


        var material = new Material();
        material.specularity = obj.specularity;
        material.diffuseMultiplier  = new Vec3(...obj.diffuseMultiplier);
        material.specularMultiplier = new Vec3(...obj.specularMultiplier);
        material.emissionMultiplier = new Vec3(...obj.emissionMultiplier);

        if(obj.diffuseImage) {
            material.setDiffuseImage(obj.diffuseImage);
        }
        if(obj.specularImage) {
            material.setSpecularImage(obj.specularImage);
        }
        if(obj.emissionImage) {
            material.setEmissionImage(obj.emissionImage);
        }

        return material;
    }


    encode(existingImagesBaseIndex) {
        var images = []

        var pushImageIfitExists = (image) => {
            if(!image) {
                return [this.NO_IMAGE_ADDRESS, 0, 0];
            }

            var imageIndex = existingImagesBaseIndex + images.length;
            images.push(image);

            return [imageIndex, image.width, image.height];
        }

        var encoded = []
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
