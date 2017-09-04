// TODO: Refactor this entire file


class App {
    async loadScene(encoded) {
        this.scene = await Scene.fromJSONEncodableObj(this.pt.gl, JSON.parse(encoded));
        this.scene.uploadSceneData();
        this.updateModelList();
    }

    render() {
        if(this.scene) {
            this.pt.renderImage(this.scene);
            this.pt.displayImage();
        }
    }

    updateModelList() {
        const listElem    = document.querySelector("#model-list");
        const rowTemplate = document.querySelector("#model-template").content;

        for(const model of this.scene.models) {
            const row = document.importNode(rowTemplate, true);

            row.querySelector(".model-name").innerText = `${model.name}`;

            row.querySelector(".model-position").appendChild(
                this.createVec3Element(model.position));
            row.querySelector(".model-size").appendChild(
                this.createVec3Element(model.size));
            row.querySelector(".model-material").appendChild(
                this.createMaterialElement(model.material));

            listElem.appendChild(row);
        }
    }

    createMaterialElement(material) {
        const template = document.querySelector("#material-template").content;
        const materialElem = document.importNode(template, true);

        const specularityElem = materialElem.querySelector(".material-specularity");
        this.enforceNumberInputFormat(specularityElem, material.specularity, [0, 1]);

        const materialDiffuseElem = materialElem.querySelector(".material-diffuse");
        const materialSpecularElem = materialElem.querySelector(".material-specular");
        const materialEmissionElem = materialElem.querySelector(".material-emission");

        materialDiffuseElem.appendChild(this.createMaterialComponentElement(material.diffuse));
        materialSpecularElem.appendChild(this.createMaterialComponentElement(material.specular));
        materialEmissionElem.appendChild(this.createMaterialComponentElement(material.emission));

        return materialElem;
    }

    createMaterialComponentElement(materialComponent) {
        if(materialComponent.isFlat) {
            return this.createColorInputElement(materialComponent.value);
        }
        else {
            return materialComponent.value;
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

        // Only register for the blur event, because altering the text while the user is trying to
        // edit it is extremely annoying
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
            const file = await loadFile();
            const fr = new FileReader();
            fr.onloadend = () => this.loadScene(fr.result);
            fr.readAsText(file);
        });

        document.querySelector("#save-button").addEventListener("click", () => {
            if(this.scene) {
                const data = JSON.stringify(this.scene.toJSONEncodableObj());
                saveFile(data, "scene.json");
            }
        });

        document.querySelector("#render-button").addEventListener("click", () => this.render());
    }
}

window.onload = async () => {
    window.app = new App();
    app.run();
};
