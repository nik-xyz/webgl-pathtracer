class TriangleVertex
    constructor: (@pos, @nor, @tex) ->


    sub: (other) -> new TriangleVertex(
        @pos.sub(other.pos),
        @nor.sub(other.nor),
        @tex.sub(other.tex)
    )


class Triangle
    constructor: (vert0, vert1, vert2, @materialIndex) ->
        @minBound = vert0.pos.min(vert1.pos).min(vert2.pos)
        @maxBound = vert0.pos.max(vert1.pos).max(vert2.pos)

        @vert  = vert0
        @edge0 = vert1.sub(vert0)
        @edge1 = vert2.sub(vert0)


    encode: ->
        verts = [@vert, @edge0, @edge1]

        posData = verts.map((v) -> v.pos.array()).reduce((a, b) -> a.concat(b))
        norData = verts.map((v) -> v.nor.array()).reduce((a, b) -> a.concat(b))
        texData = verts.map((v) -> v.tex.array()).reduce((a, b) -> a.concat(b))

        return posData.concat(norData).concat(texData).concat(@materialIndex)
