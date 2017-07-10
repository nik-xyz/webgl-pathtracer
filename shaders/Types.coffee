Shader.typesSource = """

struct Cube {
    vec3 center;
    float size;
};

struct PosTriangle {
    vec3 vert, edge0, edge1;
};

struct AuxTriangle {
    vec3 vertNor, edge0Nor, edge1Nor;
    vec2 vertTex, edge0Tex, edge1Tex;
};

const uint triangleStride = 24u;

struct Ray {
    vec3 origin, dir, inverseDir;
};
"""
