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

struct Tri {
    vec3 vert, edge0, edge1;
};

struct Ray {
    vec3 origin, dir, inverseDir;
};

struct HitTestResult {
    bool hit;
    float edge0, edge1;
    float distance;
};
"""