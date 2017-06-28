class OctreeNode
    constructor: (@center, @size, @subdivisionLimit = 10) ->
        @children = [0...8].map(-> null)
        @triangles = []


    # Find the child node that contains the given point
    mapPositionToChild: (position) =>
        bits = @center.less(position)
        return (bits.x << 2) | (bits.y << 1) | (bits.z << 0)


    # Find the the center of a given child node
    mapChildToPosition: (index) =>
        bits = new Vec3((index >> 2) & 1, (index >> 1) & 1, (index >> 0) & 1)
        return bits.map((bit) => (bit - 0.5) * @size).add(@center)


    ensureChildExists: (index) ->
        if @children[index] is null
            @children[index] = new OctreeNode(
                @mapChildToPosition(index), @size * 0.5, @subdivisionLimit - 1)


    addTriangle: (triangle) ->
        # Find which child nodes the vertices are in
        childIndices = triangle.verts.map(@mapPositionToChild)

        # If the vertices are all in the same octant, the triangle can be
        # added to a child node, otherwise it must be added it to this node
        vertsInSameOctant = childIndices.every((index) -> index == childIndices[0])

        if vertsInSameOctant and @subdivisionLimit > 0
            @ensureChildExists(childIndices[0])
            @children[childIndices[0]].addTriangle(triangle)
        else
            @triangles.push(triangle)



class Octree
    constructor: (triangles) ->
        # Compute bounding box for all triangles
        eps = 0.1
        minBound = triangles.map((tri) -> tri.minBound).reduce((a, b) -> a.min(b))
        maxBound = triangles.map((tri) -> tri.maxBound).reduce((a, b) -> a.max(b))
        center = minBound.add(maxBound).scale(0.5)
        size = maxBound.sub(minBound).reduce(Math.max) + eps

        root = new OctreeNode(center, size)
        for triangle in triangles
            root.addTriangle(triangle)