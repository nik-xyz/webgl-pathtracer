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

        listElem.innerText = "TODO: Make this editable";

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

        const asHex = vec => "#" + vec
            .map(a => a * 255)
            .map(Math.floor)
            .map(a => ("00" + a.toString(16)).substr(-2))
            .reduce((a, b) => a + b);

        materialElem.querySelector(".material-specularity").value = material.specularity;
        if(material.diffuse.isFlat) {
            materialElem.querySelector(".material-diffuse").value = asHex(material.diffuse.value);
        }
        if(material.specular.isFlat) {
            materialElem.querySelector(".material-specular").value = asHex(material.specular.value);
        }
        if(material.emission.isFlat) {
            materialElem.querySelector(".material-emission").value = asHex(material.emission.value);
        }

        return materialElem;
    }

    createVec3Element(vec, precision = 6) {
        const template = document.querySelector("#vec3-template").content;
        const vec3Elem = document.importNode(template, true);

        const query = selector => vec3Elem.querySelector(selector);
        const componentElems = [".vec3-x", ".vec3-y", ".vec3-z"].map(query);

        for(const index in componentElems) {
            const componentElem = componentElems[index];
            componentElem.value = vec.array()[index].toPrecision(precision + 1);
            componentElem.step = Math.pow(0.1, precision);
            //componentElem.addEventListener("change", )
        }

        return vec3Elem;
    }

    async run() {
        this.pt = new PathTracer();
        await this.pt.init();
        this.pt.setResolution(new Vec2(800, 800));
        this.scene = null;

        document.querySelector("#render-output").appendChild(this.pt.gl.canvas);

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
