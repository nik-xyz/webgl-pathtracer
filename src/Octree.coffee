class OctreeNode
    constructor: () ->
        @children = (null for iter in [0...8])

class Octree
    constructor: (triangles) ->
