class TriangleLoader
    NEWLINE_REGEX    = /[\r\n]+/g
    WHITESPACE_REGEX = /[\s]+/g
    VERTEX_REGEX     = /\//g

    DEFAULT_TEXCOORD = new Vec2(0, 0)


    constructor: (data) ->
        @triangles = createTriangles(getFaces(parseLines(data)...))


    createTriangles = (faces) ->
        triangles = []
        for face in faces
            # Triangulate the face
            for index in [1...(face.length - 1)]
                tri = new Triangle(face[0], face[index], face[index + 1])
                triangles.push(tri)

        triangles


    getFaces = (posArray, norArray, texArray, faceArray) ->
        for face in faceArray
            for vertIndices in face
                new TriangleVertex(
                    accessArray(posArray, vertIndices[0]),
                    accessArray(norArray, vertIndices[2]),
                    accessArray(texArray, vertIndices[1], DEFAULT_TEXCOORD),
                )


    accessArray = (array, index, alt) ->
        unless Number.isSafeInteger(index)
            if alt? then return alt
            throw "Invalid list index"

        if index < 1 or index > array.length
            throw "List index is out of range"

        return array[index - 1]


    parseLines = (data) ->
        [posArray, norArray, texArray, faceArray] = [[], [], [], []]

        for line, lineIndex in data.split(NEWLINE_REGEX)
            try
                tokens = line.trim().split(WHITESPACE_REGEX)

                if tokens.length < 1 then continue

                command = tokens[0]
                args = tokens.slice(1)

                if command is "v"
                    posArray.push(new Vec3(parseFloats(3, args)...))

                else if command is "vn"
                    norArray.push(new Vec3(parseFloats(3, args)...))

                else if command is "vt"
                    texArray.push(new Vec2(parseFloats(2, args)...))

                else if command is "f"
                    faceArray.push(args.map(parseFaceVert))

            catch error
                throw "Error parsing file on line #{lineIndex + 1}: #{error}"

        return [posArray, norArray, texArray, faceArray]


    parseFaceVert = (str) ->
        tokens = str.split(VERTEX_REGEX)
        vertAttribs = [
            [0, false, "position"],
            [1, true,  "texture coordinate"],
            [2, false, "normal"]
        ]

        for [tokenIndex, optional, name] in vertAttribs
            arrayIndex = Number.parseInt(tokens[tokenIndex])
            unless optional or Number.isSafeInteger(arrayIndex)
                throw "Vertex #{name} list index is absent or invalid"

            arrayIndex


    parseFloats = (qty, tokens) ->
        if tokens.length < num then throw "Not enough arguments"
        for index in [0...qty]
            num = Number.parseFloat(tokens[index])
            if num is NaN
                throw "Invalid float"

            num
