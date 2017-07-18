ShaderSources.getFragShaderSource = -> """
#version 300 es

precision mediump float;

in vec2 fragPos;
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
    uint rngState = rngSeed;

    Ray ray = createRay(cameraPosition, normalize(vec3(fragPos.x+random(rngState)/512., fragPos.y+random(rngState)/512., 0.8)));

    fragColor = vec4(tracePath(ray, rngState), compositeAlpha);
}


"""
