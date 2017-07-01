class OctreeNode
    constructor: (@center, @size, @subdivisionLimit = 9) ->
        @children = new Array(8).fill(null)
        @triangles = []


    # Find the child node that contains the given point
    getContainerNode: (position) =>
        bits = @center.less(position)
        return (bits.x << 2) | (bits.y << 1) | (bits.z << 0)


    # Find the the center of a given child node
    getNodeCenterPosition: (index) =>
        bits = new Vec3((index >> 2) & 1, (index >> 1) & 1, (index >> 0) & 1)
        return bits.map((bit) => (bit - 0.5) * @size * 0.5).add(@center)


    ensureChildExists: (index) ->
        if @children[index] is null
            @children[index] = new OctreeNode(
                @getNodeCenterPosition(index), @size * 0.5, @subdivisionLimit - 1)


    addTriangle: (triangle) ->
        # Find the octants that contain the triange's vertices
        childIndices = triangle.verts.map(@getContainerNode)

        # If the vertices are all in the same octant, the triangle can be
        # added to a child node, otherwise it must be added to this node
        vertsInSameOctant = childIndices.every((index) -> index is childIndices[0])

        if vertsInSameOctant and @subdivisionLimit > 0
            @ensureChildExists(childIndices[0])
            @children[childIndices[0]].addTriangle(triangle)
        else
            @triangles.push(triangle)


    encode: (octreeBuffer = [], triangleBuffer = []) ->
        # Push triangle start address
        octreeBuffer.push(triangleBuffer.length / Octree.TRIANGLE_BUFFER_CHANNELS)

        # Push triangles
        for triangle in @triangles
            triangleBuffer.push(triangle.encode()...)

        # Push triangle end address
        octreeBuffer.push(triangleBuffer.length / Octree.TRIANGLE_BUFFER_CHANNELS)

        if @children.every((child) -> child is null)
            # Push no-load flag + padding
            octreeBuffer.push(0, 0)

        else
            # Push load flag + padding
            octreeBuffer.push(1, 0)

            # Push null child addresss that will be overwritten with actual values later
            childrenSegmentAddress = octreeBuffer.length
            octreeBuffer.push(new Array(8).fill(0)...)

            # Push children and set address pointers
            for child, index in @children
                if child isnt null
                    # Set child address
                    octreeBuffer[childrenSegmentAddress + index] =
                        octreeBuffer.length / Octree.OCTREE_BUFFER_CHANNELS

                    # Push child
                    child.encode(octreeBuffer, triangleBuffer)

        return [octreeBuffer, triangleBuffer]


class Octree
    @OCTREE_BUFFER_CHANNELS   = 4
    @TRIANGLE_BUFFER_CHANNELS = 3

    constructor: (triangles) ->
        # Compute bounding box for all triangles
        eps = 0.1
        minBound = triangles.map((tri) -> tri.minBound).reduce((a, b) -> a.min(b))
        maxBound = triangles.map((tri) -> tri.maxBound).reduce((a, b) -> a.max(b))
        center = minBound.add(maxBound).scale(0.5)
        size = maxBound.sub(minBound).reduce(Math.max) + eps

        @root = new OctreeNode(center, size)
        for triangle in triangles
            @root.addTriangle(triangle)


    encode: -> @root.encode()
