RayTracer.vertShaderSource = """
attribute vec2 vertPos;
varying vec2 fragPos;

void main() {
    fragPos = vertPos;
    gl_Position = vec4(vertPos, 0.0, 1.0);
}
"""
