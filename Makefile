
SRCS  = src/App.coffee
SRCS += src/GLCommon.coffee
SRCS += src/Vec.coffee
SRCS += src/Triangle.coffee
SRCS += src/Octree.coffee
SRCS += models/TestModel.coffee
SRCS += src/TriangleLoader.coffee
SRCS += src/PathTracer.coffee
SRCS += shaders/Shader.coffee
SRCS += shaders/Types.coffee
SRCS += shaders/HitTest.coffee
SRCS += shaders/ReadData.coffee
SRCS += shaders/Vert.coffee
SRCS += shaders/Frag.coffee

compile:
	coffee --watch --join PathTracer.js --bare --compile $(SRCS)
