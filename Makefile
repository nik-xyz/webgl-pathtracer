
SRCS  = src/App.coffee
SRCS += src/GLCommon.coffee
SRCS += src/KDTree.coffee
SRCS += src/Model.coffee
SRCS += src/RandomGen.coffee
SRCS += src/Scene.coffee
SRCS += src/PathTracer.coffee

SRCS += shaders/ShaderSources.coffee
SRCS += shaders/DataTex.coffee
SRCS += shaders/Frag.coffee
SRCS += shaders/GeomHitTest.coffee
SRCS += shaders/GeomTypes.coffee
SRCS += shaders/Material.coffee
SRCS += shaders/KDTree.coffee
SRCS += shaders/PathTrace.coffee
SRCS += shaders/Random.coffee
SRCS += shaders/Scatter.coffee
SRCS += shaders/SceneHitTest.coffee
SRCS += shaders/Uniforms.coffee
SRCS += shaders/Vert.coffee

compile:
	coffee --watch --join PathTracer.js --bare --compile $(SRCS)
