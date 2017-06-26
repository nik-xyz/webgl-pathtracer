ShaderSources =
    vertex:
        """
attribute vec2 vertPos;
void main() {
    gl_Position = vec4(vertPos, 0.0, 1.0);
}
        """

    fragment:
        """
void main() {
    gl_FragColor = vec4(0.0, 0.0, 1.0, 1.0);
}
        """
