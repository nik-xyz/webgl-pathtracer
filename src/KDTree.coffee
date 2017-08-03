class KDTree
    @NULL_NODE_ADDRESS = 0
    SUBDIVISION_LIMIT = @SUBDIVISION_LIMIT = 10


    constructor: (@triangles, @limit = SUBDIVISION_LIMIT) ->
        @lowerChild = null
        @upperChild = null

        @selectSplitAxis()
        @selectSplitPoint()

        @minBound = @triangles.map((tri) -> tri.minBound).reduce((a, b) -> a.min(b))
        @maxBound = @triangles.map((tri) -> tri.maxBound).reduce((a, b) -> a.max(b))

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

        if lowerChildTriangles.length > 10
            @lowerChild = new KDTree(lowerChildTriangles, @limit - 1)
        else
            @triangles.push(lowerChildTriangles...)

        if upperChildTriangles.length > 10
            @upperChild = new KDTree(upperChildTriangles, @limit - 1)
        else
            @triangles.push(upperChildTriangles...)


    selectSplitAxis: () ->
        # TODO: Use better axis selection method. For now, cycle through axes
        @splitAxis = @limit % 3


    selectSplitPoint: () ->
        # TODO: Use better split point selection method
        # For now, use simple median
        points = @triangles.map((tri) => tri.center().array()[@splitAxis])
        points.sort()
        @splitPoint = points[Math.floor(points.length / 2)]


    encode: (treeUintBuffer = [], treeFloatBuffer = []) ->
        # Push triangles start address
        treeUintBuffer.push(treeFloatBuffer.length)

        # Push triangles
        for triangle in @triangles
            treeFloatBuffer.push(triangle.encode()...)

        # Push triangle end address, which is also the start address for
        # the split / bounds data
        treeUintBuffer.push(treeFloatBuffer.length)

        # Push split point
        treeFloatBuffer.push(@splitPoint)

        # Push bounds
        treeFloatBuffer.push(@minBound.array()..., @maxBound.array()...)

        # Push split axis
        treeUintBuffer.push(@splitAxis)

        # Push null child addresss that will be replaced with real values later
        childrenBaseAddress = treeUintBuffer.length
        treeUintBuffer.push(@NULL_NODE_ADDRESS, @NULL_NODE_ADDRESS)

        # Push children and set address pointers
        for child, index in [@lowerChild, @upperChild]
            if child isnt null
                # Set child address
                treeUintBuffer[childrenBaseAddress + index] = treeUintBuffer.length

                # Push child
                child.encode(treeUintBuffer, treeFloatBuffer)

        return [treeUintBuffer, treeFloatBuffer]
