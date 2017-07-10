
SRCS  = src/App.coffee
SRCS += src/GLCommon.coffee
SRCS += src/Vec.coffee
SRCS += src/Triangle.coffee
SRCS += src/Octree.coffee
SRCS += src/TriangleLoader.coffee
SRCS += src/PathTracer.coffee

SRCS += models/TestModel.coffee

SRCS += shaders/Shader.coffee
SRCS += shaders/Octree.coffee
SRCS += shaders/DataTex.coffee
SRCS += shaders/GeomTypes.coffee
SRCS += shaders/GeomHitTest.coffee
SRCS += shaders/SceneHitTest.coffee
SRCS += shaders/Vert.coffee
SRCS += shaders/Frag.coffee

compile:
	coffee --watch --join PathTracer.js --bare --compile $(SRCS)
