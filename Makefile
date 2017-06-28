
SRCS  = src/App.coffee
SRCS += src/GLCommon.coffee
SRCS += src/Vec3.coffee
SRCS += src/Triangle.coffee
SRCS += src/Scene.coffee
SRCS += src/RayTracer.coffee
SRCS += shaders/RayTraceVert.coffee
SRCS += shaders/RayTraceFrag.coffee

compile:
	coffee --watch --join RayTracer.js --bare --compile $(SRCS)
