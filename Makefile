
SRCS  = src/Shaders.coffee
SRCS += src/App.coffee
SRCS += src/RayTracer.coffee

compile:
	coffee --watch --join RayTracer.js --compile $(SRCS)
