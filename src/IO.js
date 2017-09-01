const loadFile = () => {
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
};

const saveFile = (data, name) =>  {
    const link = document.createElement("a");
    link.href = "data:text/plain," + encodeURIComponent(data);
    link.download = name;
    link.style.display = "none";
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
};

const assertJSONHasKeys = (json, keys) => {
    for(const key of keys) {
        if(!(key in json)) {
            throw new Error(`invalid JSON: missing required key ${key}`);
        }
    }
};
