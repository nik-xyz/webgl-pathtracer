class Triangle
    constructor: (vert0, vert1, vert2) ->
        @verts = [vert0, vert1, vert2]

        @minBound = @verts.reduce((a, b) -> a.min(b))
        @maxBound = @verts.reduce((a, b) -> a.max(b))

        # Pick the vertex that is the closest to the center to be the base
        center = @verts.reduce((a, b) -> a.add(b)).scale(1 / 3)
        distances = @verts.map((vert) -> vert.dist(center))

        selector = (best, dist, index) -> (if dist < distances[best] then index else best)
        closest = distances.reduce(selector, 0)

        @base = @verts[closest]
        @edge0 = @verts[(closest + 1) % 3].sub(@base)
        @edge1 = @verts[(closest + 2) % 3].sub(@base)


    encode: ->
        return @base.array().concat(@edge0.array()).concat(@edge1.array())
