
SRCS  = src/App.coffee
SRCS += src/GLCommon.coffee
SRCS += src/RayTracer.coffee
SRCS += shaders/RayTraceVert.coffee
SRCS += shaders/RayTraceFrag.coffee

compile:
	coffee --watch --join RayTracer.js --compile $(SRCS)
