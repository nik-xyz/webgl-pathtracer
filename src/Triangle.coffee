class Triangle
    constructor: (vert0, vert1, vert2) ->
        @verts = [vert0, vert1, vert2]

        @minBound = @verts.reduce((a, b) -> a.min(b))
        @maxBound = @verts.reduce((a, b) -> a.max(b))


    closestVertToCenter = (verts) ->
        center = verts.reduce((a, b) -> a.add(b)).scale(1 / 3)
        distances = verts.map((vert) -> vert.dist(center))

        selector = (best, dist, index) ->
            if dist < distances[best] then index else best

        return distances.reduce(selector, 0)


    encode: ->
        closest = closestVertToCenter(@verts)
        vertIndex = (index) -> (closest + index) % 3

        vert  = @verts[vertIndex(0)]
        edge0 = @verts[vertIndex(1)].sub(vert)
        edge1 = @verts[vertIndex(2)].sub(vert)
        return [vert, edge0, edge1]
            .map((v) -> v.array())
            .reduce((a, b) -> a.concat(b))
