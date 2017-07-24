ShaderSources.getGeomTypesSource = -> """
const uint TRIANGLE_STRIDE = 25u;


// Triangle position data. Only positions are needed for ray-triangle hit tests.
struct TrianglePosData {
    vec3 vert, edge0, edge1;
};


// Auxiliary triangle data. Only needed when the triangle has been determined
// to be intersected by a ray.
struct TriangleAuxAttribs {
    vec3 vertNor, edge0Nor, edge1Nor;
    vec2 vertTex, edge0Tex, edge1Tex;
    uint materialIndex;
};


struct Cube {
    vec3 center;
    float size;
};


struct Ray {
    vec3 origin, dir, inverseDir;
};


Ray createRay(vec3 origin, vec3 dir) {
    // TODO: check div-by-0 behavior in WebGL2 spec
    return Ray(origin, dir, 1.0 / dir);
}


"""
