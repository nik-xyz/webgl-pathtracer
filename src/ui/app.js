class App {
    async loadScene(encoded) {
        this.scene = await Scene.fromJSONEncodableObj(this.pt.gl, JSON.parse(encoded));
        this.updateModelList();
        this.sceneChanged = true;
    }

    render() {
        if(this.sceneChanged) {
            this.pt.reset();
            this.scene.uploadSceneData();
            this.sceneChanged = false;
        }

        if(this.scene) {
            this.pt.renderImage(this.scene);
            this.pt.displayImage();
        }
    }

    updateModelList() {
        const elem = document.querySelector("#model-list");

        // Clear list
        while(elem.lastChild) {
            elem.removeChild(elem.lastChild);
        }

        for(const model of this.scene.models) {
            elem.appendChild(this.createModelElement(model));
        }
    }

    async addModel() {
        const text = await loadFileText();
        const model = await ModelInstance.fromJSONEncodableObj({
            name:     "Unnamed Model",
            model:    text,
            material: Material.DEFAULT_MATERIAL_JSON,
            position: ModelInstance.DEFAULT_POSITION.array(),
            size:     ModelInstance.DEFAULT_SIZE.array()
        });

        this.scene.addModelAtStart(model);
        this.updateModelList();

        this.sceneChanged = true;
    }

    createModelElement(model) {
        const template = document.querySelector("#model-template").content;
        const elem = document.importNode(template, true);

        const fill = (selector, value) => elem.querySelector(selector).appendChild(value);

        fill(".model-name",     document.createTextNode(model.name));
        fill(".model-position", this.createVec3Element(model.position));
        fill(".model-size",     this.createVec3Element(model.size));
        fill(".model-material", this.createMaterialElement(model.material));

        return elem;
    }

    createMaterialElement(material) {
        const template = document.querySelector("#material-template").content;
        const elem = document.importNode(template, true);

        const specularityElem = elem.querySelector(".material-specularity");
        this.enforceNumberInputFormat(specularityElem, material.specularity, [0, 1]);

        const fill = (selector, value) => elem.querySelector(selector).appendChild(value);

        fill(".material-diffuse",  this.createMaterialComponentElement(material.diffuse));
        fill(".material-specular", this.createMaterialComponentElement(material.specular));
        fill(".material-emission", this.createMaterialComponentElement(material.emission));

        return elem;
    }

    createMaterialComponentElement(materialComponent) {
        if(materialComponent.isFlat) {
            return this.createColorInputElement(materialComponent.value);
        }
        else {
            const img = new Image();
            img.src = materialComponent.value.src;
            return img;
        }
    }

    createColorInputElement(initialColor) {
        const asHex = vec => "#" + vec
            .map(a => a * 255)
            .map(Math.floor)
            .map(a => ("00" + a.toString(16)).substr(-2))
            .reduce((a, b) => a + b);

        const elem = document.createElement("input");
        elem.type = "color";
        elem.value = asHex(initialColor);
        return elem;
    }

    createVec3Element(vec, precision = 6) {
        const template = document.querySelector("#vec3-template").content;
        const vec3Elem = document.importNode(template, true);

        const componentElems = ["x", "y", "z"].map(axis => vec3Elem.querySelector(".vec3-" + axis));

        for(const index in componentElems) {
            const limits = [Number.NEGATIVE_INFINITY, Number.POSITIVE_INFINITY];
            this.enforceNumberInputFormat(componentElems[index], vec.array()[index], limits);
        }

        return vec3Elem;
    }

    enforceNumberInputFormat(elem, initialValue, limits, precision = 6) {
        // Suggest that the browser maintain this format
        elem.step = Math.pow(0.1, precision);
        elem.min = limits[0];
        elem.max = limits[1];

        const setWithFormat = value => {
            elem.value = value.toFixed(precision);
        };

        setWithFormat(initialValue);

        // Value to return to if the input becomes invalid
        let lastGoodValue = initialValue;

        // Only register for the blur event, because altering the text while the user is
        // trying to edit it is extremely annoying
        elem.addEventListener("blur", () => {
            const newValue = Number.parseFloat(elem.value);
            const safeValue = Number.isNaN(newValue) ? lastGoodValue : newValue;
            const clampedValue = Math.min(Math.max(safeValue, limits[0]), limits[1]);
            lastGoodValue = clampedValue;
            setWithFormat(clampedValue);
        });
    }

    async run() {
        this.pt = new PathTracer();
        await this.pt.init();
        this.pt.setResolution(new Vec2(800, 800));
        this.scene = null;

        document.querySelector("#render-output").appendChild(this.pt.canvas);

        document.querySelector("#load-button").addEventListener("click", async () => {
            this.loadScene(await loadFileText());
        });

        document.querySelector("#save-button").addEventListener("click", () => {
            if(this.scene) {
                const data = JSON.stringify(this.scene.toJSONEncodableObj());
                saveFile(data, "scene.json");
            }
        });

        document.querySelector("#render-button").addEventListener("click", () => this.render());

        document.querySelector("#add-model-button").addEventListener("click", () => this.addModel());
    }
}

window.onload = async () => {
    window.app = new App();
    app.run();
};
