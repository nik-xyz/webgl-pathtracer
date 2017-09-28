class App {
    async loadScene(encoded) {
        try {
            const newScene = await Scene.fromJSON(this.pt.gl, JSON.parse(encoded));
            this.scene = newScene;
            this.updateUI();
            this.sceneChanged = true;
        }
        catch(err) {
            alert(`Failed to load scene:\n${err.message}`);
        }
    }

    async loadDemo() {
        fetch("scenes/scene.json")
            .then(response => response.text())
            .then(text => this.loadScene(text));
    }

    async addModel() {
        try {
            const model = await ModelInstance.fromJSON({
                name:     "Unnamed Model",
                model:    await loadFileText(),
                material: Material.DEFAULT_MATERIAL_JSON,
                position: ModelInstance.DEFAULT_POSITION.array(),
                rotation: ModelInstance.DEFAULT_ROTATION.array(),
                size:     ModelInstance.DEFAULT_SIZE.array()
            });

            this.scene.addModelAtStart(model);
            this.updateUI();

            this.sceneChanged = true;
        }
        catch(err) {
            alert(`Failed to load model:\n${err.message}`);
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

    updateUI() {
        const cameraContainer = document.querySelector("#camera-container");
        const modelContainer = document.querySelector("#model-list");

        this.clearElement(cameraContainer);
        this.clearElement(modelContainer);

        cameraContainer.appendChild(this.createCameraElement(this.scene.camera));

        for(const model of this.scene.models) {
            modelContainer.appendChild(this.createModelElement(model));
        }
    }

    createCameraElement(camera) {
        const template = document.querySelector("#camera-template").content;
        const elem = document.importNode(template, true);

        const fill = (selector, value) => elem.querySelector(selector).appendChild(value);

        fill(".camera-position", this.createVec3InputElement(camera.position, value => {
            camera.position = value;
            this.sceneChanged = true;
        }));

        fill(".camera-rotation", this.createVec3InputElement(camera.rotation, value => {
            camera.rotation = value;
            this.sceneChanged = true;
        }));

        const handleFovyChange = value => {
            camera.fovy = value;
            this.sceneChanged = true;
        };
        fill(".camera-fovy", this.createNumberInputElement(
            camera.fovy, Camera.FOVY_RANGE, 2, handleFovyChange
        ));

        return elem;
    }

    createModelElement(model) {
        const template = document.querySelector("#model-template").content;
        const elem = document.importNode(template, true);
        const fill = (selector, value) => elem.querySelector(selector).appendChild(value);

        fill(".model-name", this.createTextInputElement(model.name, value => {
            model.name = value;
            this.sceneChanged = true;
        }));

        fill(".model-position", this.createVec3InputElement(model.position, value => {
            model.position = value;
            this.sceneChanged = true;
        }));

        fill(".model-rotation", this.createVec3InputElement(model.rotation, value => {
            model.rotation = value;
            this.sceneChanged = true;
        }));

        fill(".model-size", this.createVec3InputElement(model.size, value => {
            model.size = value;
            this.sceneChanged = true;
        }));

        fill(".model-grid", this.createMaterialElement(model.material));

        elem.querySelector(".model-delete-button").addEventListener("click", () => {
            if(confirm(`Delete ${model.name}?`)) {
                this.scene.removeModel(model);
                this.updateUI();
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

        const fill = (selector, value) => elem.querySelector(selector).appendChild(value);

        const handleSpecularityChange = value => {
            material.specularity = value;
            this.sceneChanged = true;
        };

        fill(".material-specularity", this.createNumberInputElement(
            material.specularity, Material.SPECULARITY_RANGE, 3, handleSpecularityChange
        ));
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

    createVec3InputElement(currentValue, handleChange, precision = 5) {
        const template = document.querySelector("#vec3-template").content;
        const elem = document.importNode(template, true);
        const fill = (selector, value) => elem.querySelector(selector).appendChild(value);

        for(let axis of ["x", "y", "z"]) {
            const input = this.createNumberInputElement(
                currentValue[axis],
                [Number.NEGATIVE_INFINITY, Number.POSITIVE_INFINITY],
                precision,
                axisValue => {
                    currentValue[axis] = axisValue;
                    handleChange(currentValue);
                }
            );

            fill(`.vec3-${axis}`, input);
        }

        return elem;
    }

    createNumberInputElement(currentValue, limits, precision, handleChange) {
        const elem = document.createElement("input");
        elem.type = "number";

        const setWithFormat = value => {
            currentValue = value;
            elem.value = value.toFixed(precision);
        };

        setWithFormat(currentValue);

        elem.addEventListener("blur", () => {
            const newValue = Number.parseFloat(elem.value);
            const safeValue = Number.isNaN(newValue) ? currentValue : newValue;
            const clampedValue = Math.min(Math.max(safeValue, limits[0]), limits[1]);

            setWithFormat(clampedValue);

            handleChange(clampedValue);
        });

        return elem;
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
