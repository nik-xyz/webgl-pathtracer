
SRCS  = src/App.coffee
SRCS += src/GLCommon.coffee
SRCS += src/Vec.coffee
SRCS += src/Triangle.coffee
SRCS += src/Octree.coffee
SRCS += src/TriangleLoader.coffee
SRCS += src/RandomGen.coffee
SRCS += src/Material.coffee
SRCS += src/Scene.coffee
SRCS += src/PathTracer.coffee

SRCS += models/TestModel.coffee

SRCS += shaders/ShaderSources.coffee
SRCS += shaders/DataTex.coffee
SRCS += shaders/Frag.coffee
SRCS += shaders/GeomHitTest.coffee
SRCS += shaders/GeomTypes.coffee
SRCS += shaders/Material.coffee
SRCS += shaders/Octree.coffee
SRCS += shaders/PathTrace.coffee
SRCS += shaders/Random.coffee
SRCS += shaders/Scatter.coffee
SRCS += shaders/SceneHitTest.coffee
SRCS += shaders/Uniforms.coffee
SRCS += shaders/Vert.coffee

compile:
	coffee --watch --join PathTracer.js --bare --compile $(SRCS)
