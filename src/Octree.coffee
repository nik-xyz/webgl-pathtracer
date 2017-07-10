class OctreeNode
    NULL_NODE_ADDRESS = 0
    NO_LOAD_FLAG      = 0
    LOAD_FLAG         = 1


    constructor: (@center, @size, @limit) ->
        @children = new Array(8).fill(null)
        @triangles = []


    # Find the child node that contains the given point
    getContainerNode: (position) =>
        bits = @center.less(position)
        return (bits.x << 2) | (bits.y << 1) | (bits.z << 0)


    # Find the the center of a given child node
    getNodeCenterPosition: (index) =>
        bits = new Vec3((index >> 2) & 1, (index >> 1) & 1, (index >> 0) & 1)
        return bits.map((bit) => (bit - 0.5) * @size).add(@center)


    ensureChildExists: (index) =>
        if @children[index] is null
            center = @getNodeCenterPosition(index)
            @children[index] = new OctreeNode(center, @size * 0.5, @limit - 1)


    addTriangle: (triangle) ->
        # Find the octants that contain the triange's vertices
        minBoundOctant = @getContainerNode(triangle.minBound)
        maxBoundOctant = @getContainerNode(triangle.maxBound)

        # If the vertices are all in the same octant, the triangle can be
        # added to a child node, otherwise it must be added to this one
        if minBoundOctant is maxBoundOctant and @limit > 0
            @ensureChildExists(minBoundOctant)
            @children[minBoundOctant].addTriangle(triangle)
        else
            @triangles.push(triangle)


    encode: (octreeBuffer = [], triangleBuffer = []) ->
        # Push triangle start address
        octreeBuffer.push(triangleBuffer.length)

        # Push triangles
        for triangle in @triangles
            triangleBuffer.push(triangle.encode()...)

        # Push triangle end address
        octreeBuffer.push(triangleBuffer.length)

        if @children.every((child) -> child is null)
            # Push no-load flag
            octreeBuffer.push(NO_LOAD_FLAG)
        else
            # Push load flag
            octreeBuffer.push(LOAD_FLAG)

            # Push null child addresss that will be overwritten with actual values later
            childrenSegmentBaseAddress = octreeBuffer.length
            octreeBuffer.push(new Array(8).fill(NULL_NODE_ADDRESS)...)

            # Push children and set address pointers
            for child, index in @children
                if child isnt null
                    # Set child address
                    octreeBuffer[childrenSegmentBaseAddress + index] = octreeBuffer.length

                    # Push child
                    child.encode(octreeBuffer, triangleBuffer)

        return [octreeBuffer, triangleBuffer]


class Octree
    SUBDIVISION_LIMIT = 10

    constructor: (triangles, eps = 0.1, limit = SUBDIVISION_LIMIT) ->
        # Compute bounding box for all triangles
        minBound = triangles.map((tri) -> tri.minBound).reduce((a, b) -> a.min(b))
        maxBound = triangles.map((tri) -> tri.maxBound).reduce((a, b) -> a.max(b))
        center = minBound.add(maxBound).scale(0.5)
        size = maxBound.sub(minBound).reduce(Math.max) + eps

        @root = new OctreeNode(center, size, limit)

        for triangle in triangles
            @root.addTriangle(triangle)


    encode: -> @root.encode()
