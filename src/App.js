class App {
    // Just testing code right now so it's not properly structured at all
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
        const listElem    = document.querySelector("#scene-model-list");
        const rowTemplate = document.querySelector("#scene-model-row-template").content;

        let i = 0;
        for(const model of this.scene.models) {
            const row = document.importNode(rowTemplate, true);

            // TODO: assign sensible names
            row.querySelector(".scene-model-name").innerText = `Model ${i++}`;

            row.querySelector(".scene-model-position").innerText = model.position.array();
            row.querySelector(".scene-model-size").innerText = model.size.array();

            listElem.appendChild(row);
        }
    }

    async run() {
        this.pt = new PathTracer();
        await this.pt.init();
        this.pt.setResolution(new Vec2(512, 512));
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
