class ShaderProgram {
    constructor(gl, shaderData, uniformNames = []) {
        this.gl = gl;

        const shaders = ShaderProgram.createShaders(gl, shaderData);
        window.x=shaderData
        ShaderProgram.checkShaders(this.gl, shaders);
        this.program = this.gl.createProgram();

        for(const shader of shaders) {
            this.gl.attachShader(this.program, shader);
        }

        this.gl.linkProgram(this.program);

        for(const shader of shaders) {
            this.gl.detachShader(this.program, shader);
            this.gl.deleteShader(shader);
        }

        this.setupUniforms(uniformNames);
    }

    use() {
        this.gl.useProgram(this.program);
    }

    static createShaders(gl, shaderData) {
        const shaders = [];

        for(const [type, source] of shaderData) {
            const shader = gl.createShader(type);
            gl.shaderSource(shader, source);
            gl.compileShader(shader);
            shaders.push(shader);
        }
        return shaders;
    }

    static checkShaders(gl, shaders) {
        for(const shader of shaders) {
            if(!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
                const log = gl.getShaderInfoLog(shader);

                for(const shaderToDelete of shaders) {
                    gl.deleteShader(shaderToDelete);
                }

                throw new Error(`shader compilation failed:\n${log}`);
            }
        }
    }

    setupUniforms(names) {
        this.uniforms = {};

        for(const name of names) {
            const loc = this.gl.getUniformLocation(this.program, name);
            if(!loc) {
                console.error(`failed to locate uniform ${name}`);
            }

            this.uniforms[name] = loc;
        }
    }
}

class Texture {
    constructor(
        gl, size, internalFormat, format, type, data,
        filter = WebGL2RenderingContext.NEAREST
    ) {
        this.gl = gl;
        this.size = size;
        this.tex = gl.createTexture();
        gl.bindTexture(gl.TEXTURE_2D, this.tex);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, filter);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, filter);
        gl.texImage2D(gl.TEXTURE_2D, 0, internalFormat, size.x, size.y, 0,
            format, type, data);
    }

    bind(unit) {
        this.gl.activeTexture(unit);
        this.gl.bindTexture(this.gl.TEXTURE_2D, this.tex);
    }

    destroy() {
        this.gl.deleteTexture(this.tex);
    }
}

class ArrayTexture {
    constructor(
        gl, size, layers, internalFormat, format, type, images,
        filter = WebGL2RenderingContext.LINEAR,
        wrap = WebGL2RenderingContext.REPEAT
    ) {
        this.gl = gl;
        this.size = size;
        this.layers = layers;

        this.tex = gl.createTexture();
        gl.bindTexture(gl.TEXTURE_2D_ARRAY, this.tex);
        gl.texParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_MIN_FILTER, filter);
        gl.texParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_MAG_FILTER, filter);
        gl.texParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_WRAP_S, wrap);
        gl.texParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_WRAP_T, wrap);
        gl.texStorage3D(gl.TEXTURE_2D_ARRAY, 1, internalFormat, size.x, size.y,
            images.length);

        for(let index = 0; index < images.length; index++) {
            const image = images[index];
            gl.texSubImage3D(gl.TEXTURE_2D_ARRAY, 0, 0, 0, index,
                image.width, image.height, 1, format, type, image);
        }
    }

    bind(unit) {
        this.gl.activeTexture(unit);
        this.gl.bindTexture(this.gl.TEXTURE_2D_ARRAY, this.tex);
    }

    destroy() {
        this.gl.deleteTexture(this.tex);
    }
}

class DataTexture extends Texture {
    constructor(gl, type, data) {
        // Find the array types and image formats for the data
        let arrayType, internalFormat, format;
        if(type === gl.FLOAT) {
            arrayType      = Float32Array;
            internalFormat = gl.R32F;
            format         = gl.RED;
        }
        else if(type === gl.UNSIGNED_INT) {
            arrayType      = Uint32Array;
            internalFormat = gl.R32UI;
            format         = gl.RED_INTEGER;
        }
        else {
            throw new Error("data type not supported");
        }
        // TODO: might not need to do this with NPOT textures
        // Must pad the data to be a power-of-two length
        // so that it can be uploaded to a power-of-two texture
        const paddedSize = Math.pow(2, Math.ceil(Math.log2(data.length)));

        // Check data fits inside texture size limits
        const sizeLimit = gl.getParameter(gl.MAX_TEXTURE_SIZE);
        if(paddedSize > sizeLimit * sizeLimit) {
            throw new Error("required texture size exceeds limit");
        }
        // Avoid copying if the original array meets the necessary requirements
        if(!(data instanceof arrayType) || (data.length === paddedSize)) {
            const paddedData = new arrayType(paddedSize);
            paddedData.set(data);
            data = paddedData;
        }
        // Choose width and height so that the texture is large enough
        // to store the data while staying inside the size limits
        const width = Math.min(paddedSize, sizeLimit);
        const height = paddedSize / Math.max(width, 1);

        // Create texture
        super(gl, new Vec2(width, height), internalFormat, format, type, data);

        // Calculate address mask and shift values to allow
        // the texture to be accessed with a 1D index
        this.dataMaskAndShift = [width - 1, Math.log2(width)];
    }
}

class VertexArray {
    constructor(gl){
        this.gl = gl;
        this.vao = gl.createVertexArray();
    }

    setupAttrib(location, buffer, size, type, stride = 0, offset = 0) {
        this.bind();
        buffer.bind();
        this.gl.enableVertexAttribArray(location);
        this.gl.vertexAttribPointer(location, size, type, false, stride, offset);
    }

    bind() {
        this.gl.bindVertexArray(this.vao);
    }
}

class Framebuffer {
    constructor(gl, resolution) {
        this.gl = gl;
        this.resolution = resolution;

        const floatExt = gl.getExtension("EXT_color_buffer_float");
        const internalFormat = floatExt ? gl.RGBA32F : gl.RGBA8;

        this.buf = gl.createFramebuffer();
        gl.bindFramebuffer(gl.FRAMEBUFFER, this.buf);

        this.rb = gl.createRenderbuffer();
        gl.bindRenderbuffer(gl.RENDERBUFFER, this.rb);

        gl.renderbufferStorage(gl.RENDERBUFFER, internalFormat,
            this.resolution.x, this.resolution.y);

        gl.framebufferRenderbuffer(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0,
            gl.RENDERBUFFER, this.rb);

        gl.bindRenderbuffer(gl.RENDERBUFFER, null);
        gl.bindFramebuffer(gl.FRAMEBUFFER, null);
    }

    destroy() {
        this.gl.deleteFramebuffer(this.buf);
        this.gl.deleteRenderbuffer(this.rb);
    }
}
