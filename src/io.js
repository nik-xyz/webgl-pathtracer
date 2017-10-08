const loadFileText = () => {
    const fileInput = document.createElement("input");
    fileInput.type = "file";

    const loadPromise = new Promise((resolve, reject) => {
        fileInput.addEventListener("change", event => {
            event.preventDefault();
            if(fileInput.files.length === 0) {
                reject();
            }
            else {
                const fr = new FileReader();
                fr.onloadend = () => resolve(fr.result);
                fr.readAsText(fileInput.files[0]);
            }
        });
    });

    fileInput.click();
    return loadPromise;
};

const loadFileAsURL = async () => {
    const fileInput = document.createElement("input");
    fileInput.type = "file";

    const loadPromise = new Promise((resolve, reject) => {
        fileInput.addEventListener("change", event => {
            event.preventDefault();
            if(fileInput.files.length === 0) {
                reject();
            }
            else {
                const fr = new FileReader();
                fr.onloadend = () => resolve(fr.result);
                fr.readAsDataURL(fileInput.files[0]);
            }
        });
    });

    fileInput.click();
    return loadPromise;
};

const saveFile = (data, name) =>  {
    const link = document.createElement("a");
    link.href = URL.createObjectURL(new Blob([data]));
    link.download = name;
    link.style.display = "none";
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    URL.revokeObjectURL(link.href);
};

const assertJSONHasKeys = (json, keys) => {
    for(const key of keys) {
        if(!(key in json)) {
            throw new Error(`invalid JSON: missing required key ${key}`);
        }
    }
};
