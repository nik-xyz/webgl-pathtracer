class RandomGen {
    // Hack: define 'constants' with const getters
    static get RANDOM_DATA_LENGTH() { return 1 << 12; }

    constructor(gl) {
        this.gl = gl;
        this.randomData = new Float32Array(RandomGen.RANDOM_DATA_LENGTH);
        this.randomDataTex = null;
    }

    createRandomData() {
        for(var index = 0; index < this.randomData.length; index++) {
            this.randomData[index] = Math.random();
        }

        if(this.randomDataTex) {
            this.randomDataTex.destroy();
        }
        this.randomDataTex = new DataTexture(this.gl, this.gl.FLOAT, this.randomData);
    }

    bind(program) {
        this.randomDataTex.bind(this.gl.TEXTURE3);

        this.gl.uniform1i(program.uniforms.randomBufferSampler, 3);
        this.gl.uniform2uiv(program.uniforms.randomBufferAddrData,
            this.randomDataTex.dataMaskAndShift);
    }
}
