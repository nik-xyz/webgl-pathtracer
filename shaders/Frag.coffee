ShaderSources.getFragShaderSource = -> """
#version 300 es

precision mediump float;

in  highp vec2 fragPos;
out highp vec4 fragColor;

// Include other shaders
#{ShaderSources.getUniformsSource()}
#{ShaderSources.getGeomTypesSource()}
#{ShaderSources.getOctreeSource()}
#{ShaderSources.getDataTexSource()}
#{ShaderSources.getGeomHitTestSource()}
#{ShaderSources.getSceneHitTestSource()}
#{ShaderSources.getRandomSource()}
#{ShaderSources.getPathTraceSource()}

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


"""
