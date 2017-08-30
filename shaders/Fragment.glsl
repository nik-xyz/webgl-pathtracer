in  highp vec2 fragPos;
out highp vec4 fragColor;

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
