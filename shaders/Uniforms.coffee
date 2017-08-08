ShaderSources.getUniformsSource = -> """
uniform sampler2D treeFloatBufferSampler;
uniform uvec2 treeFloatBufferAddrData;

uniform highp usampler2D treeUintBufferSampler;
uniform uvec2 treeUintBufferAddrData;

uniform sampler2D materialBufferSampler;
uniform uvec2 materialBufferAddrData;

uniform sampler2D randomBufferSampler;
uniform uvec2 randomBufferAddrData;

uniform highp sampler2DArray materialTexArraySampler;

uniform vec3 cameraPosition;
uniform vec2 subPixelJitter;
uniform highp float compositeAlpha;


"""

ShaderSources.uniformNames = [
    "treeFloatBufferSampler"
    "treeFloatBufferAddrData"

    "treeUintBufferSampler"
    "treeUintBufferAddrData"

    "materialBufferSampler"
    "materialBufferAddrData"

    "randomBufferSampler"
    "randomBufferAddrData"

    "materialTexArraySampler"

    "cameraPosition"

    "subPixelJitter"
    "compositeAlpha"
]
