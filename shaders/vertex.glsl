out vec2 fragPos;

const vec2 quadPositions[] = vec2[](
    vec2(-1, -1),
    vec2(-1,  1),
    vec2( 1,  1),
    vec2( 1,  1),
    vec2( 1, -1),
    vec2(-1, -1)
);

void main() {
    fragPos = quadPositions[gl_VertexID];
    gl_Position = vec4(fragPos, 0.0, 1.0);
}
