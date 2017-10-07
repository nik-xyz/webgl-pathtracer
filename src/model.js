class Model {
    // Hack: define 'constants' with getters
    static get NEWLINE_REGEX()    { return /[\r\n]+/g;  }
    static get WHITESPACE_REGEX() { return /[\s]+/g;    }
    static get VERTEX_REGEX()     { return /\//g;       }
    static get DEFAULT_TEXCOORD() { return new Vec2(0); }

    constructor(data) {
        this.data = data;
        this.parseLines();
    }

    toJSON() {
        return this.data;
    }

    static fromJSON(obj) {
        if(typeof obj !== "string") {
            throw new Error("invalid JSON");
        }

        return new Model(obj);
    }

    getTriangles(transforms, materialIndex) {
        return this.getFaces(transforms, materialIndex)
            .map(poly => poly.triangulate())
            .reduce((a, b) => a.concat(b));
    }

    getFaces(transforms, materialIndex) {
        const facePolys = [];

        for(const face of this.faceArray) {
            const vertices = [];

            for(const indices of face) {
                const pos = Model.accessArray(this.posArray, indices.pos);
                const nor = Model.accessArray(this.norArray, indices.nor);
                const tex = Model.accessArray(this.texArray, indices.tex, Model.DEFAULT_TEXCOORD);

                vertices.push(new Vertex(pos, nor, tex).transform(transforms));
            }
            facePolys.push(new Polygon(vertices, materialIndex));
        }
        return facePolys;
    }

    parseLines() {
        this.posArray  = [];
        this.norArray  = [];
        this.texArray  = [];
        this.faceArray = [];

        const lines = this.data.split(Model.NEWLINE_REGEX);

        for(let index = 0; index < lines.length; index++) {
            try {
                this.parseLine(lines[index]);
            }
            catch(error) {
                throw new Error(`parsing file on line ${index + 1}: ${error}`);
            }
        }
    }

    parseLine(line) {
        const tokens = line.trim().split(Model.WHITESPACE_REGEX);
        if(tokens.length < 1) {
            return;
        }

        const args = tokens.slice(1);

        switch(tokens[0]) {
            case "v":
                const pos = new Vec3(...Model.parseFloats(3, args)).mul(new Vec3(-1, 1, 1));
                this.posArray.push(pos);
                break;

            case "vn":
                const nor = new Vec3(...Model.parseFloats(3, args)).mul(new Vec3(-1, 1, 1));
                this.norArray.push(nor);
                break;

            case "vt":
                const tex = new Vec2(...Model.parseFloats(2, args));
                this.texArray.push(tex);
                break;

            case "f":
                this.faceArray.push(args.map(Model.parseVertex));
                break;
        }
    }

    static accessArray(array, index, alt) {
        if(Number.isSafeInteger(index)) {
            if (1 <= index && index <= array.length) {
                return array[index - 1];
            }
            throw new Error("list index out of range");
        }
        if(typeof alt !== "undefined") {
            return alt;
        }
        throw new Error("invalid list index");
    }

    static parseVertex(str) {
        const tokens = str.split(Model.VERTEX_REGEX);

        // Attributes of the data that is described by a single vertex string.
        const vertexComponents = [
            { key: "pos", tokenIndex: 0, required: true,  desc: "position"},
            { key: "tex", tokenIndex: 1, required: false, desc: "texture coordinate"},
            { key: "nor", tokenIndex: 2, required: true,  desc: "normal"}
        ];

        const vertex = {};

        for(const comp of vertexComponents) {
            // Try to parse the component's token to get the array index
            let arrayIndex = NaN;
            if (tokens.length > comp.tokenIndex) {
                arrayIndex = Number.parseInt(tokens[comp.tokenIndex]);
            }

            vertex[comp.key] = arrayIndex;

            if(!Number.isSafeInteger(arrayIndex) && comp.required) {
                throw new Error(`vertex ${comp.desc} list index is absent or invalid`);
            }
        }

        return vertex;
    }

    static parseFloats(count, tokens) {
        if(tokens.length < count) {
            throw new Error("not enough numbers provided");
        }

        const values = tokens.slice(0, count).map(Number.parseFloat);

        if(values.some(Number.isNaN)) {
            throw new Error("invalid number provided");
        }

        return values;
    }
}
