ShaderSources.getUniformsSource = -> """
uniform sampler2D triangleBufferSampler;
uniform uvec2 triangleBufferAddrData;

uniform highp usampler2D treeBufferSampler;
uniform uvec2 treeBufferAddrData;

uniform sampler2D materialBufferSampler;
uniform uvec2 materialBufferAddrData;

uniform sampler2D randomBufferSampler;
uniform uvec2 randomBufferAddrData;

uniform vec3 cameraPosition;
uniform vec2 subPixelJitter;
uniform highp float compositeAlpha;


"""

ShaderSources.uniformNames = [
    "triangleBufferSampler"
    "triangleBufferAddrData"

    "treeBufferSampler"
    "treeBufferAddrData"

    "materialBufferSampler"
    "materialBufferAddrData"

    "randomBufferSampler"
    "randomBufferAddrData"

    "cameraPosition"

    "subPixelJitter"
    "compositeAlpha"
]
