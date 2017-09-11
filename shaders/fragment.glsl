in  highp vec2 fragPos;
out highp vec4 fragColor;

void main() {
    uint rngState = 0u;

    vec3 projected = cameraProjectionMatrix * vec3(fragPos + subPixelJitter, 1.0);
    Ray ray = createRay(cameraPosition, normalize(projected));

    fragColor = vec4(tracePath(ray, rngState), compositeAlpha);
}
