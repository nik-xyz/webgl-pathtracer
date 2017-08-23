class App {
    // Just testing code right now (i.e. not properly structured at all)
    constructor() {
        this.pt = new PathTracer();
        this.pt.setResolution(new Vec2(512, 512));
    }

    render() {
        this.pt.renderImage();
        this.pt.displayImage();
    }

    load() {
        const fileInput = document.createElement("input");
        fileInput.type = "file";

        const loadPromise = new Promise((resolve, reject) => {
            fileInput.addEventListener("change", event => {
                event.preventDefault();
                if(fileInput.files.length === 0) {
                    reject();
                }
                else {
                    resolve(fileInput.files[0]);
                }
            });
        });

        fileInput.click();
        return loadPromise;
    }

    save(data, name) {
        const link = document.createElement("a");
        link.href = "data:text/plain," + encodeURIComponent(data);
        link.download = name;
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    }

    run() {
        const renderControls = document.getElementById("render-controls");

        const loadButton = document.createElement("input");
        loadButton.value = "Load scene";
        loadButton.type = "button";
        loadButton.addEventListener("click", async () => {
            const file = await this.load();
            const fr = new FileReader();
            fr.onloadend = () => this.pt.loadScene(fr.result);
            fr.readAsText(file);
        });
        renderControls.appendChild(loadButton);

        const saveButton = document.createElement("input");
        saveButton.value = "Save scene";
        saveButton.type = "button";
        saveButton.addEventListener("click", () => {
            const data = JSON.stringify(this.pt.scene.toJSONEncodableObj());
            this.save(data, "scene.json");
        });
        renderControls.appendChild(saveButton);

        const renderButton = document.createElement("input");
        renderButton.value = "Render";
        renderButton.type = "button";
        renderButton.addEventListener("click", () => this.render());
        renderControls.appendChild(renderButton);

        const renderOutput = document.getElementById("render-output");
        renderOutput.appendChild(this.pt.getCanvas());
    }
}

window.onload = () => {
    window.app = new App();
    app.run();
};
