class Camera {
    static get FOVY_RANGE() { return [0, 90]; }

    static get DEFAULT_CAMERA_JSON() {
        return {
            position: [0, 0, 0],
            rotation: [0, 0, 0],
            fovy:     30,
        }
    }

    static fromJSON(json) {
        assertJSONHasKeys(json, ["position", "rotation", "fovy"]);
        if(!Number.isFinite(json.fovy)) {
            throw new Error("Invalid JSON!");
        }

        const camera = new Camera();

        camera.position = Vec3.fromJSON(json.position).checkNumeric();
        camera.rotation = Vec3.fromJSON(json.rotation).checkNumeric();
        camera.fovy = Number.parseFloat(json.fovy);

        return camera;
    }

    toJSON() {
        return {
            position: this.position.array(),
            rotation: this.rotation.array(),
            fovy:     this.fovy
        };
    }

    // Creates 2x3 matrix that maps a 2D normalized device coordinate to the
    // direction of the ray that is projected through it
    createCameraMatrix(ratio) {
        // Project the x and y components onto the plane (Z = 1)
        const projX = Math.tan(this.fovy / 180 * Math.PI);
        const projY = projX / ratio;

        const matrix = [
            new Vec3(projX, 0, 0).rotateEuler(this.rotation, true),
            new Vec3(0, projY, 0).rotateEuler(this.rotation, true),
            new Vec3(0, 0,     1).rotateEuler(this.rotation, true)
        ];

        return matrix.map(vec => vec.array()).reduce((a, b) => a.concat(b));
    }

    bindCamera(gl, program, aspectRatio) {
        gl.uniform3fv(program.uniforms.cameraPosition, this.position.array());
        const matrix = this.createCameraMatrix(aspectRatio);
        gl.uniformMatrix3fv(program.uniforms.cameraProjectionMatrix, false, matrix);
    }
}
