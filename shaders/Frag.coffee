Shader.fragShaderSource = """
#version 300 es

precision mediump float;

in  vec2 fragPos;
out vec4 fragColor;

uniform vec3 cameraPosition;

uniform vec3 octreeCubeCenter;
uniform float octreeCubeSize;


""" + Shader.geomTypesSource    + """
""" + Shader.octreeSource       + """
""" + Shader.dataTexSource      + """
""" + Shader.geomHitTestSource  + """
""" + Shader.sceneHitTestSource + """


void main() {
    vec3 dir = normalize(vec3(fragPos.x, fragPos.y, 0.9));
    Ray ray = Ray(cameraPosition, dir, 1.0 / dir);

    SceneHitTestResult res = hitTestScene(ray);

    fragColor = vec4(res.nor, 1.0);
}

"""
