RayTracer.fragShaderSource = """
precision mediump float;

varying mediump vec2 fragPos;

vec4 hitTest(vec3 origin, vec3 direction) {
    return vec4(direction, 1.0);
}

void main() {
    vec3 origin = vec3(0.0, 0.0, 0.0);
    vec3 direction = normalize(vec3(fragPos.x, fragPos.y, 1.0));

    gl_FragColor = hitTest(origin, direction);
}

"""
