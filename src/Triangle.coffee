class Triangle
    constructor: (@vert0, @vert1, @vert2) ->


    encode: ->
        # Pick the vertex that is the closest to the centeroid to be the base
        center = @vert0.add(@vert1).add(@vert2).scale(1 / 3)
        verts = [@vert0, @vert1, @vert2]
        distances = (vert.dist(center) for vert in verts)

        closest = if distances[0] < distances[1] then 0 else 1
        closest = if distances[closest] < distances[2] then closest else 2

        base = verts[closest]
        edge0 = verts[(closest + 1) % 3].sub(base)
        edge1 = verts[(closest + 2) % 3].sub(base)

        return base.array().concat(edge0.array()).concat(edge1.array())
