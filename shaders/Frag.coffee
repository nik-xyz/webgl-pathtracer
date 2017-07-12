ShaderSources.getFragShader = -> """
#version 300 es

precision mediump float;

in vec2 fragPos;
out highp vec4 fragColor;


#{ShaderSources.getUniforms()}
#{ShaderSources.getGeomTypes()}
#{ShaderSources.getOctree()}
#{ShaderSources.getDataTex()}
#{ShaderSources.getGeomHitTest()}
#{ShaderSources.getSceneHitTest()}


vec4 tracePath(Ray startRay) {
    // TODO: path tracing

    SceneHitTestResult res = hitTestScene(startRay);

    if(!res.hit) {
        // TODO: sample background map instead
        return vec4(0.0, 0.0, 0.0, 1.0);
    }

    return vec4(res.tex, 1.0 - res.tex.x - res.tex.y, 1.0);
}


void main() {
    Ray ray = createRay(cameraPosition, normalize(vec3(fragPos.x, fragPos.y, 0.9)));
    fragColor = tracePath(ray);
}


"""
