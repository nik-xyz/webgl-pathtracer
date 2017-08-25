class App {
    // Just testing code right now so it's not properly structured at all
    constructor() {
        this.pt = new PathTracer();
        this.pt.setResolution(new Vec2(512, 512));
        this.scene = null;
    }

    async loadScene(encoded) {
        this.scene = await Scene.fromJSONEncodableObj(this.pt.gl, JSON.parse(encoded));
        this.scene.uploadSceneData();
    }

    render() {
        if(this.scene) {
            this.pt.renderImage(this.scene);
            this.pt.displayImage();
        }
    }

    run() {
        document.getElementById("load-button").addEventListener("click", async () => {
            const file = await loadFile();
            const fr = new FileReader();
            fr.onloadend = () => this.loadScene(fr.result);
            fr.readAsText(file);
        });

        document.getElementById("save-button").addEventListener("click", () => {
            const data = JSON.stringify(this.pt.scene.toJSONEncodableObj());
            saveFile(data, "scene.json");
        });

        document.getElementById("render-button")
            .addEventListener("click", () => this.render());

        document.getElementById("render-output").appendChild(this.pt.gl.canvas);
    }
}

window.onload = () => {
    window.app = new App();
    app.run();
};
