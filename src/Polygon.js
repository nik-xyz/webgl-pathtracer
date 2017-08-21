class Vertex {
    constructor(pos, nor, tex) {
        [this.pos, this.nor, this.tex] = [pos, nor, tex];
    }

    sub(other) {
        return new Vertex(
            this.pos.sub(other.pos),
            this.nor.sub(other.nor),
            this.tex.sub(other.tex)
        );
    }

    transform(transforms) {
        return new Vertex(
            transforms.pos(this.pos),
            transforms.nor(this.nor),
            transforms.tex(this.tex)
        );
    }
}

class Triangle {
    constructor(vert0, vert1, vert2, materialIndex) {
        this.materialIndex = materialIndex;

        this.minBound = vert0.pos.min(vert1.pos).min(vert2.pos);
        this.maxBound = vert0.pos.max(vert1.pos).max(vert2.pos);

        this.vert = vert0;
        this.edge0 = vert1.sub(vert0);
        this.edge1 = vert2.sub(vert0);
    }

    center() {
        return this.vert.pos
            .add(this.edge0.pos.scale(1 / 3))
            .add(this.edge1.pos.scale(1 / 3));
    }

    encode() {
        const verts = [this.vert, this.edge0, this.edge1];

        const posData = verts.map((v) => v.pos.array());
        const norData = verts.map((v) => v.nor.array());
        const texData = verts.map((v) => v.tex.array());

        return Array.prototype.concat(
            ...posData, ...norData, ...texData, this.materialIndex);
    }
}

class Polygon {
    constructor(verts, materialIndex) {
        this.verts = verts;
        this.materialIndex = materialIndex;
    }

    /* Reduces polygon to triangle fan */
    triangulate() {
        const triangles = [];
        for(let index = 0; index < this.verts.length - 1; index++) {
            triangles.push(new Triangle(
                this.verts[0],
                this.verts[index + 0],
                this.verts[index + 1],
                this.materialIndex
            ));
        }

        return triangles;
    }
}
