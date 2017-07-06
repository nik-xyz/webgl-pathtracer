class Triangle
    constructor: (vert0, vert1, vert2) ->
        @minBound = vert0.min(vert1).min(vert2)
        @maxBound = vert0.max(vert1).max(vert2)
        
        @vert  = vert0
        @edge0 = vert1.sub(vert0)
        @edge1 = vert2.sub(vert0)

    encode: ->
        return [@vert, @edge0, @edge1]
            .map((v) -> v.array())
            .reduce((a, b) -> a.concat(b))
