Shader.vertShaderSource = """
#version 300 es

in vec2 vertPos;
out vec2 fragPos;

void main() {
    fragPos = vertPos;
    gl_Position = vec4(vertPos, 0.0, 1.0);
}
"""
