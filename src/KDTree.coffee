class KDTree
    @NULL_NODE_ADDRESS = 0
    SUBDIVISION_LIMIT = @SUBDIVISION_LIMIT = 10


    constructor: (@triangles, @limit = SUBDIVISION_LIMIT) ->
        @lowerChild = null
        @upperChild = null
        @selectSplitAxis()
        @selectSplitPoint()

        if @limit > 0
            @addTrianglesToChildren()


    addTrianglesToChildren: () ->
        newTriangles = []
        lowerChildTriangles = []
        upperChildTriangles = []

        for triangle in @triangles
            # If the triangle is entirely on one side of the split plane,
            # add it to the appropriate child
            if triangle.maxBound.array()[@splitAxis] <= @splitPoint
                lowerChildTriangles.push(triangle)

            else if triangle.minBound.array()[@splitAxis] >= @splitPoint
                upperChildTriangles.push(triangle)
            else
                newTriangles.push(triangle)

        @triangles = newTriangles
        if lowerChildTriangles.length > 0
            @lowerChild = new KDTree(lowerChildTriangles, @limit - 1)
        if upperChildTriangles.length > 0
            @upperChild = new KDTree(upperChildTriangles, @limit - 1)


    selectSplitAxis: () ->
        # TODO: Use better axis selection method. For now, cycle through axes
        @splitAxis = @limit % 3


    selectSplitPoint: () ->
        # TODO: Use better split point selection method
        # For now, use simple median
        points = @triangles.map((tri) => tri.center().array()[@splitAxis])
        points.sort()
        @splitPoint = points[Math.floor(points.length / 2)]


    encode: (treeBuffer = [], triangleBuffer = []) ->
        # Push triangle start address
        treeBuffer.push(triangleBuffer.length)

        # Push triangles
        for triangle in @triangles
            triangleBuffer.push(triangle.encode()...)

        # Push triangle end address
        treeBuffer.push(triangleBuffer.length)

        # Push null child addresss that will be replaced with real values later
        childrenBaseAddress = treeBuffer.length
        treeBuffer.push(@NULL_NODE_ADDRESS, @NULL_NODE_ADDRESS)

        # Push children and set address pointers
        for child, index in [@lowerChild, @upperChild]
            if child isnt null
                # Set child address
                treeBuffer[childrenBaseAddress + index] = treeBuffer.length

                # Push child
                child.encode(treeBuffer, triangleBuffer)

        return [treeBuffer, triangleBuffer]
