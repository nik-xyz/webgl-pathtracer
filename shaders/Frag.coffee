Shader.fragShaderSource = """
#version 300 es

precision mediump float;

in vec2 fragPos;
out highp vec4 fragColor;

uniform vec3 cameraPosition;

uniform vec3 octreeCubeCenter;
uniform float octreeCubeSize;


""" + Shader.geomTypesSource    + """
""" + Shader.octreeSource       + """
""" + Shader.dataTexSource      + """
""" + Shader.geomHitTestSource  + """
""" + Shader.sceneHitTestSource + """


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
