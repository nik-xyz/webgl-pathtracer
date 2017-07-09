class TriangleLoader
    NEWLINE_REGEX    = /[\r\n]+/g
    WHITESPACE_REGEX = /[\s]+/g
    VERTEX_REGEX     = /\//g


    constructor: (data) ->
        arrays = parseLines(data)
        @triangles = createTriangles(arrays...)


    createTriangles = (posArray, norArray, texArray, faceArray) ->
        triangles = []
        for face in faceArray
            # TODO: Triangulate face instead
            if face.length isnt 3 then continue

            positions = []
            for vert in face
                # TODO: check range
                positions.push(posArray[vert[0] - 1])

            triangles.push(new Triangle(positions...))

        return triangles


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
                throw "Error parsing file on line #{lineIndex + 1}:\n#{error}"

        return [posArray, norArray, texArray, faceArray]


    parseFaceVert = (str) ->
        tokens = str.split(VERTEX_REGEX)
        vertAttribs = [
            [0, true],  # Position
            [1, false], # Texture Coordinate
            [2, true]   # Normal
        ]

        for [tokenIndex, required] in vertAttribs
            if tokens.length < tokenIndex or tokens[tokenIndex] is ""
                if required then throw "Required integer not present"
                NaN
            else
                num = Number.parseInt(tokens[tokenIndex])
                unless Number.isSafeInteger(num) then throw "Invalid integer"
                num


    parseFloats = (qty, tokens) ->
        if tokens.length < num then throw "Not enough arguments"
        for index in [0...qty]
            num = Number.parseFloat(tokens[index])
            if num is NaN then throw "Invalid float"
            num
