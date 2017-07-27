ShaderSources.getUniformsSource = -> """
uniform sampler2D triangleBufferSampler;
uniform uvec2 triangleBufferAddrData;

uniform highp usampler2D octreeBufferSampler;
uniform uvec2 octreeBufferAddrData;

uniform sampler2D materialBufferSampler;
uniform uvec2 materialBufferAddrData;

uniform sampler2D randomBufferSampler;
uniform uvec2 randomBufferAddrData;

uniform vec3 octreeCubeCenter;
uniform float octreeCubeSize;

uniform vec3 cameraPosition;
uniform vec2 subPixelJitter;
uniform highp float compositeAlpha;


"""

ShaderSources.uniformNames = [
    "triangleBufferSampler"
    "triangleBufferAddrData"

    "octreeBufferSampler"
    "octreeBufferAddrData"

    "materialBufferSampler"
    "materialBufferAddrData"

    "randomBufferSampler"
    "randomBufferAddrData"

    "octreeCubeCenter"
    "octreeCubeSize"

    "cameraPosition"

    "subPixelJitter"
    "compositeAlpha"
]
