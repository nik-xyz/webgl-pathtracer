class RandomGen
    @RANDOM_DATA_LENGTH = 1 << 12


    constructor: (@gl) ->
        @randomData = new Float32Array(RandomGen.RANDOM_DATA_LENGTH)


    createRandomData: ->
        for index in [0...@randomData.length]
            @randomData[index] = Math.random()

        if @randomDataTex? then @randomDataTex.destroy()
        @randomDataTex = new DataTexture(@gl, @gl.FLOAT, @randomData)


    uploadData: (program) ->
        @randomDataTex.bind(@gl.TEXTURE2)

        @gl.uniform1i( program.uniforms["randomBufferSampler"], 2)
        @gl.uniform1ui(program.uniforms["randomBufferMask"],  @randomDataTex.dataMask)
        @gl.uniform1ui(program.uniforms["randomBufferShift"], @randomDataTex.dataShift)
