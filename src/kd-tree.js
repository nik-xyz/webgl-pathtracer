class KDTree {
    // Hack: define 'constants' with const getters
    static get NULL_NODE_ADDRESS()  { return 0; }
    static get SUBDIVISION_LIMIT()  { return 10; }
    static get MIN_NODE_TIRANGLES() { return 10; }

    constructor(triangles, limit = KDTree.SUBDIVISION_LIMIT) {
        this.triangles = triangles;
        this.limit     = limit;

        this.lowerChild = null;
        this.upperChild = null;

        this.selectSplitAxis();
        this.selectSplitPoint();

        this.minBound = this.triangles.map(tri => tri.minBound).reduce((a, b) => a.min(b));
        this.maxBound = this.triangles.map(tri => tri.maxBound).reduce((a, b) => a.max(b));

        if(this.limit > 0) {
            this.addTrianglesToChildren();
        }
    }

    addTrianglesToChildren() {
        const newTriangles = [];
        const lowerChildTriangles = [];
        const upperChildTriangles = [];

        for(const triangle of this.triangles) {
            // If the triangle is entirely on one side of the split plane,
            // add it to the appropriate child, otherwise add it to this node
            if(this.project(triangle.maxBound) <= this.splitPoint) {
                lowerChildTriangles.push(triangle);
            }
            else if(this.project(triangle.minBound) >= this.splitPoint) {
                upperChildTriangles.push(triangle);
            }
            else {
                newTriangles.push(triangle);
            }
        }

        this.triangles = newTriangles;

        if(lowerChildTriangles.length > KDTree.MIN_NODE_TIRANGLES) {
            this.lowerChild = new KDTree(lowerChildTriangles, this.limit - 1);
        }
        else {
            this.triangles.push(...lowerChildTriangles);
        }

        if(upperChildTriangles.length > KDTree.MIN_NODE_TIRANGLES) {
            this.upperChild = new KDTree(upperChildTriangles, this.limit - 1);
        }
        else {
            this.triangles.push(...upperChildTriangles);
        }
    }

    selectSplitAxis() {
        // TODO: Use better axis selection method. For now, cycle through axes
        this.splitAxis = this.limit % 3;
    }

    selectSplitPoint() {
        // TODO: Use better split point selection method
        // For now, use simple median
        const points = this.triangles.map((tri) => this.project(tri.center()));
        points.sort();
        this.splitPoint = points[Math.floor(points.length / 2)];
    }

    /* Projects a vector along this node's split axis */
    project(vec) {
        return vec.array()[this.splitAxis];
    }

    encode(treeUintBuffer = [], treeFloatBuffer = []) {
        // Push triangles start address
        treeUintBuffer.push(treeFloatBuffer.length);

        // Push triangles
        for(const triangle of this.triangles) {
            treeFloatBuffer.push(...triangle.encode());
        }

        // Push triangle end address, which is also the start address for
        // other data
        treeUintBuffer.push(treeFloatBuffer.length);

        // Push the split point, bounds
        treeFloatBuffer.push(this.splitPoint);
        treeFloatBuffer.push(...this.minBound.array(), ...this.maxBound.array());

        // Push split axis
        treeUintBuffer.push(this.splitAxis);

        // Push null child addresss that will be replaced with real values later
        const childrenBaseAddr = treeUintBuffer.length;
        treeUintBuffer.push(KDTree.NULL_NODE_ADDRESS, KDTree.NULL_NODE_ADDRESS);

        // Push children and set address pointers
        const children = [this.lowerChild, this.upperChild];
        for(let index = 0; index < children.length; index++) {
            const child = children[index];
            if(child) {
                // Set child address
                treeUintBuffer[childrenBaseAddr + index] = treeUintBuffer.length;

                // Recursively encode child into buffer
                child.encode(treeUintBuffer, treeFloatBuffer);
            }
        }

        return [treeUintBuffer, treeFloatBuffer];
    }
}
