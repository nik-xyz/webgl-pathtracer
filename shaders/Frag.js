ShaderSources.getFragShaderSource = async () => `#version 300 es

precision mediump float;

in  highp vec2 fragPos;
out highp vec4 fragColor;

// Include other shader source components
${await fetch("shaders/Uniforms.glsl")    .then(response => response.text())}
${await fetch("shaders/GeomTypes.glsl")   .then(response => response.text())}
${await fetch("shaders/KDTree.glsl")      .then(response => response.text())}
${await fetch("shaders/Material.glsl")    .then(response => response.text())}
${await fetch("shaders/DataTex.glsl")     .then(response => response.text())}
${await fetch("shaders/Random.glsl")      .then(response => response.text())}
${await fetch("shaders/GeomHitTest.glsl") .then(response => response.text())}
${await fetch("shaders/SceneHitTest.glsl").then(response => response.text())}
${await fetch("shaders/Scatter.glsl")     .then(response => response.text())}
${await fetch("shaders/PathTrace.glsl")   .then(response => response.text())}

void main() {
    uint rngState = 0u;

    mat3 cameraMat = mat3(
        1.000,  0.000,  0.000,
        0.000,  0.707,  0.707,
        0.000, -0.707,  0.707
    );

    vec3 projected = cameraMat * vec3(fragPos + subPixelJitter, 1.5);
    Ray ray = createRay(cameraPosition, normalize(projected));

    fragColor = vec4(tracePath(ray, rngState), compositeAlpha);
}
`;
