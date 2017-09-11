class App {
    async loadScene(encoded) {
        try {
            const newScene = await Scene.fromJSON(this.pt.gl, JSON.parse(encoded));
            this.scene = newScene;
            this.updateModelList();
            this.sceneChanged = true;
        }
        catch(err) {
            alert(`Failed to load scene:\n${err.message}`);
        }
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

    clearElement(elem) {
        while(elem.lastChild) {
            elem.removeChild(elem.lastChild);
        }
    }


    updateModelList() {
        const elem = document.querySelector("#model-list");

        this.clearElement(elem);

        for(const model of this.scene.models) {
            elem.appendChild(this.createModelElement(model));
        }
    }

    async addModel() {
        try {
            const model = await ModelInstance.fromJSON({
                name:     "Unnamed Model",
                model:    await loadFileText(),
                material: Material.DEFAULT_MATERIAL_JSON,
                position: ModelInstance.DEFAULT_POSITION.array(),
                size:     ModelInstance.DEFAULT_SIZE.array()
            });

            this.scene.addModelAtStart(model);
            this.updateModelList();

            this.sceneChanged = true;
        }
        catch(err) {
            alert(`Failed to load model:\n${err.message}`);
        }
    }

    createModelElement(model) {
        const template = document.querySelector("#model-template").content;
        const elem = document.importNode(template, true);

        const fill = (selector, value) => elem.querySelector(selector).appendChild(value);

        const handlePositionChange = value => {
            model.position = value;
            this.sceneChanged = true;
        };

        const handleSizeChange = value => {
            model.size = value;
            this.sceneChanged = true;
        };

        const handleNameChange = value => {
            model.name = value;
            this.sceneChanged = true;
        };


        fill(".model-name", this.createTextInputElement(model.name, handleNameChange));
        fill(".model-position", this.createVec3InputElement(model.position, handlePositionChange));
        fill(".model-size", this.createVec3InputElement(model.size, handleSizeChange));
        fill(".model-grid", this.createMaterialElement(model.material));

        elem.querySelector(".model-delete-button").addEventListener("click", () => {
            if(confirm(`Delete ${model.name}?`)) {
                this.scene.removeModel(model);
                this.updateModelList();
                this.sceneChanged = true;
            }
        });

        const modelElem = elem.querySelector(".model");
        elem.querySelector(".model-edit-button").addEventListener("click", () => {
            modelElem.classList.toggle("edit-enabled");
        });

        return elem;
    }

    createMaterialElement(material) {
        const template = document.querySelector("#material-template").content;
        const elem = document.importNode(template, true);

        const specularityElem = elem.querySelector(".material-specularity");
        this.enforceNumberInputFormat(
            specularityElem, material.specularity, Material.SPECULARITY_LIMITS, 3);

        specularityElem.addEventListener("change", () => {
            material.specularity = Number.parseFloat(specularityElem.value);
            this.sceneChanged = true;
        });

        const fill = (selector, value) => elem.querySelector(selector).appendChild(value);

        fill(".material-diffuse",  this.createMaterialComponentElement(material.diffuse));
        fill(".material-specular", this.createMaterialComponentElement(material.specular));
        fill(".material-emission", this.createMaterialComponentElement(material.emission));

        return elem;
    }

    createMaterialComponentElement(component) {
        const handleChange = value => {
            component.value = value;
            this.sceneChanged = true;
        };

        const template = document.querySelector("#material-component-template").content;
        const elem = document.importNode(template, true);

        const materialElem = elem.querySelector(".material-component");
        const buttonElem = elem.querySelector(".material-component-button");
        const valueElem = elem.querySelector(".material-component-value");

        const updateComponent = () => {
            this.clearElement(valueElem);

            if(component.isFlat) {
                const flat = this.createColorInputElement(component.value, handleChange);
                valueElem.appendChild(flat);
                materialElem.classList.add("material-component-flat");
            }
            else {
                const image = new Image();
                image.src = component.value.src;
                valueElem.appendChild(image);
                materialElem.classList.remove("material-component-flat");
            }
        };

        updateComponent();

        buttonElem.addEventListener("click", async () => {
            if(materialElem.classList.contains("material-component-flat")) {
                component.setImage(await loadFileAsURL());
            }
            else {
                component.setFlat(new Vec3(0));
            }

            this.sceneChanged = true;
            updateComponent();
        });

        return elem;
    }

    createTextInputElement(initialValue, handleChange) {
        const elem = document.createElement("input");
        elem.type = "text";
        elem.value = initialValue;

        elem.addEventListener("change", () => {
            handleChange(elem.value);
        });

        return elem;
    }

    createColorInputElement(initialColor, handleChange) {
        const colorAsHex = vec => "#" + vec
            .map(a => a * 255)
            .map(Math.floor)
            .map(a => ("00" + a.toString(16)).substr(-2))
            .reduce((a, b) => a + b);

        const colorAsVec = hex => {
            const rgb = [1, 3, 5]
                .map(index => hex.substr(index, 2))
                .map(num   => Number.parseInt(num, 16) / 255.0);
            return new Vec3(...rgb);
        }

        const elem = document.createElement("input");
        elem.type = "color";
        elem.value = colorAsHex(initialColor);

        elem.addEventListener("change", () => {
            handleChange(colorAsVec(elem.value));
        });

        return elem;
    }

    createVec3InputElement(vec, handleChange, precision = 5) {
        const template = document.querySelector("#vec3-template").content;
        const vec3Elem = document.importNode(template, true);

        let currentValue = vec;

        for(let axis of ["x", "y", "z"]) {
            const component = vec3Elem.querySelector(`.vec3-${axis}`);
            const limits = [Number.NEGATIVE_INFINITY, Number.POSITIVE_INFINITY];
            this.enforceNumberInputFormat(component, currentValue[axis], limits, precision);

            component.addEventListener("blur", () => {
                currentValue[axis] = Number.parseFloat(component.value);
                handleChange(currentValue);
            });
        }

        return vec3Elem;
    }

    enforceNumberInputFormat(elem, initialValue, limits, precision) {
        let lastGoodValue;
        const setWithFormat = value => {
            lastGoodValue = value;
            elem.value = value.toFixed(precision);
        };

        setWithFormat(initialValue);

        elem.addEventListener("blur", () => {
            const newValue = Number.parseFloat(elem.value);
            const safeValue = Number.isNaN(newValue) ? lastGoodValue : newValue;
            const clampedValue = Math.min(Math.max(safeValue, limits[0]), limits[1]);

            setWithFormat(clampedValue);
        });
    }


    async loadDemo() {
        fetch("scenes/scene.json")
            .then(response => response.text())
            .then(text => this.loadScene(text));
    }

    async run() {
        this.pt = new PathTracer();
        await this.pt.init();
        this.pt.setResolution(new Vec2(1000, 1000));
        this.scene = null;

        document.querySelector("#render-output").appendChild(this.pt.canvas);

        document.querySelector("#load-button").addEventListener("click", async () => {
            this.loadScene(await loadFileText());
        });

        document.querySelector("#save-button").addEventListener("click", () => {
            if(this.scene) {
                saveFile(JSON.stringify(this.scene.toJSON()), "scene.json");
            }
        });

        document.querySelector("#render-button").addEventListener("click", () => {
            this.render();
        });

        document.querySelector("#add-model-button").addEventListener("click", () => {
            this.addModel();
        });
    }
}

window.onload = async () => {
    window.app = new App();
    app.run();
};
