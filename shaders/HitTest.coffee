Shader.hitTestSource = """

struct HitTestResult {
    bool hit;
    float edge0, edge1;
    float distance;
};

/* Möller-Trumbore based ray-triangle intersection test */
HitTestResult hitTestTri(Triangle tri, Ray ray) {
    const float eps = 0.000001;

    HitTestResult res;
    res.hit = false;

    vec3 rayCrossEdge0 = cross(ray.dir, tri.edge0);
    float det = dot(rayCrossEdge0, tri.edge1);

    if(abs(det) < eps) {
        return res;
    }

    float inverseDet = 1.0 / det;
    vec3 vertToOrigin = ray.origin - tri.vert;
    res.edge1 = dot(vertToOrigin, rayCrossEdge0) * inverseDet;

    if(res.edge1 < 0.0 || res.edge1 > 1.0) {
        return res;
    }

    vec3 vertToOriginCrossEdge1 = cross(vertToOrigin, tri.edge1);

    res.edge0 = dot(ray.dir, vertToOriginCrossEdge1) * inverseDet;

    if(res.edge0 < 0.0 || res.edge0 + res.edge1 > 1.0 + eps) {
        return res;
    }

    res.distance = dot(tri.edge0, vertToOriginCrossEdge1) * inverseDet;

    res.hit = true;
    return res;
}


bool hitTestCube(Cube cube, Ray ray) {
    vec3 originToCenter = cube.center - ray.origin;
    vec3 vert0 = (originToCenter - cube.size) * ray.inverseDir;
    vec3 vert1 = (originToCenter + cube.size) * ray.inverseDir;
    vec3 closeVec = min(vert0, vert1);
    vec3 farVec   = max(vert0, vert1);
    float close   = max(closeVec.x, max(closeVec.y, closeVec.z));
    float far     = min(farVec.x,   min(farVec.y,   farVec.z));
    return close <= far;
}
"""
