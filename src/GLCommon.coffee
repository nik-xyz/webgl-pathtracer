GLCommon =
    createShader: (gl, shaderData) ->
        shaders = []

        for [type, source] in shaderData
            shader = gl.createShader(type)
            shaders.push(shader)

            gl.shaderSource(shader, source)
            gl.compileShader(shader)

            if not gl.getShaderParameter(shader, gl.COMPILE_STATUS)
                log = gl.getShaderInfoLog(shader)

                for shader in shaders
                    gl.deleteShader(shader)

                throw "Shader compilation failed:\n#{log}"

        program = gl.createProgram()

        for shader in shaders
            gl.attachShader(program, shader)

        gl.linkProgram(program)

        for shader in shaders
            gl.detachShader(program, shader)
            gl.deleteShader(shader)

        return program


    createBuffer: (gl, data, usage) ->
        buffer = gl.createBuffer()
        gl.bindBuffer(gl.ARRAY_BUFFER, buffer)
        gl.bufferData(gl.ARRAY_BUFFER, data, usage, 0)
        return buffer
