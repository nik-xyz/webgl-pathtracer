Shader.typesSource =
"""
struct Octree {
    uint triStartAddress;
    uint triEndAddress;
    uint childAddresses[8];
};

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

struct Ray {
    vec3 origin, dir, inverseDir;
};
"""
