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

    download(data, name) {
        const link = document.createElement("a");
        link.href = "data:text/plain," + encodeURIComponent(data);
        link.download = name;
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    }

    run() {
        const renderButton = document.createElement("input");
        renderButton.value = "Render!";
        renderButton.type = "button";
        renderButton.addEventListener("click", this.render.bind(this));

        const downloadButton = document.createElement("input");
        downloadButton.value = "Download scene!";
        downloadButton.type = "button";
        downloadButton.addEventListener("click", () => {
            const data = JSON.stringify(this.pt.scene.toJSONEncodableObj());
            this.download(data, "scene.json");
        });

        const fileInput = document.createElement("input");
        fileInput.value = "Upload scene!";
        fileInput.type = "file";

        const uploadButton = document.createElement("input");
        uploadButton.value = "Upload scene!";
        uploadButton.type = "button";
        uploadButton.addEventListener("click", () => {
            const fr = new FileReader();
            fr.onloadend = () => this.pt.loadScene(fr.result);
            fr.readAsText(fileInput.files[0]);
        });

        document.body.appendChild(fileInput);
        document.body.appendChild(uploadButton);
        document.body.appendChild(document.createElement("br"));
        document.body.appendChild(renderButton);
        document.body.appendChild(downloadButton);
        document.body.appendChild(document.createElement("br"));
        document.body.appendChild(this.pt.getCanvas());
    }
}

window.onload = () => {
    window.app = new App();
    app.run();
};
