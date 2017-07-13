ShaderSources.getFragShaderSource = -> """
#version 300 es

precision mediump float;

in vec2 fragPos;
out highp vec4 fragColor;

#{ShaderSources.getUniformsSource()}
#{ShaderSources.getGeomTypesSource()}
#{ShaderSources.getOctreeSource()}
#{ShaderSources.getDataTexSource()}
#{ShaderSources.getGeomHitTestSource()}
#{ShaderSources.getSceneHitTestSource()}
#{ShaderSources.getPathTraceSource()}

void main() {
    Ray ray = createRay(cameraPosition, normalize(vec3(fragPos.x, fragPos.y, 0.8)));
    fragColor = vec4(tracePath(ray), 1.0);
}


"""
