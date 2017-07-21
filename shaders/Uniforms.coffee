ShaderSources.getUniformsSource = -> """
uniform sampler2D triangleBufferSampler;
uniform uint triangleBufferMask;
uniform uint triangleBufferShift;

uniform highp usampler2D octreeBufferSampler;
uniform uint octreeBufferMask;
uniform uint octreeBufferShift;

uniform sampler2D randomBufferSampler;
uniform uint randomBufferMask;
uniform uint randomBufferShift;

uniform vec3 cameraPosition;
uniform vec2 subPixelJitter;

uniform vec3 octreeCubeCenter;
uniform float octreeCubeSize;

uniform uint rngSeed;
uniform highp float compositeAlpha;

"""
