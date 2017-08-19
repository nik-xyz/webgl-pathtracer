class Model {
    constructor(data, position = Model.DEFAULT_POSITION, size = Model.DEFAULT_SIZE) {
        this.data = data;
        this.position = position;
        this.size = size;
        this.parseLines();
    }

    toJSONEncodableObj() {
        return {
            data:     this.data,
            position: this.position.array(),
            size:     this.size.array()
        };
    }

    static fromJSONEncodableObj(obj) {
        if(!("data" in obj) || !("position" in obj) || !("size" in obj)) {
            throw new Error("invalid JSON");
        }
        // TODO: validate data fully

        return new Model(
            obj.data,
            new Vec3(...obj.position),
            new Vec3(...obj.size)
        );
    }

    getTriangles(materialIndex) {
        var triangles = [];

        for(var face of this.getFaces()) {
            // Triangulate the face
            for(var index = 0; index < face.length - 1; index++) {
                const tri = new Triangle(
                    face[0], face[index], face[index + 1], materialIndex);
                triangles.push(tri);
            }
        }
        return triangles;
    }

    getFaces() {
        // TODO: move elsewhere!
        const transform = pos => pos.mul(this.size).add(this.position);

        var faces = [];
        for(var face of this.faceArray) {
            var faceVertices = [];
            for(var indices of face) {
                const vertex = new TriangleVertex(
                    transform(Model.accessArray(this.posArray, indices.pos)),
                    Model.accessArray(this.norArray, indices.nor),
                    Model.accessArray(this.texArray, indices.tex,
                        Model.DEFAULT_VERTEX_TEXCOORD)
                );
                faceVertices.push(vertex);
            }
            faces.push(faceVertices);
        }
        return faces;
    }

    parseLines() {
        this.posArray  = [];
        this.norArray  = [];
        this.texArray  = [];
        this.faceArray = [];

        const lines = this.data.split(Model.NEWLINE_REGEX);

        for(const index in lines) {
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
                this.posArray.push(new Vec3(...Model.parseFloats(3, args)));
                break;

            case "vn":
                this.norArray.push(new Vec3(...Model.parseFloats(3, args)));
                break;

            case "vt":
                this.texArray.push(new Vec2(...Model.parseFloats(2, args)));
                break;

            case "f":
                this.faceArray.push(args.map(Model.parseVertex));
                break;
        }
    }

    static accessArray(array, index, alt) {
        if(Number.isSafeInteger(index)) {
            // The index starts from one
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

        var vertex = {};

        for(const comp of vertexComponents) {
            // Try to parse the component's token to get the array index
            var arrayIndex = NaN;
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

        var values = tokens.slice(0, count).map(Number.parseFloat);

        if(values.some(Number.isNaN)) {
            throw new Error("invalid number provided");
        }

        return values;
    }
}

// TODO: move
Model.NEWLINE_REGEX    = /[\r\n]+/g;
Model.WHITESPACE_REGEX = /[\s]+/g;
Model.VERTEX_REGEX     = /\//g;
Model.DEFAULT_VERTEX_TEXCOORD = new Vec2(0);
Model.DEFAULT_POSITION        = new Vec3(0);
Model.DEFAULT_SIZE            = new Vec3(1);
