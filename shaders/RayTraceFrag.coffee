RayTracer.fragShaderSource = """
precision mediump float;
varying vec2 fragPos;


struct Tri {
    vec3 vert, edge0, edge1;
};


struct Ray {
    vec3 origin, dir;
};


struct HitTestResult {
    bool hit;
    float edge0, edge1;
    float distance;
};


HitTestResult hitTest(Tri tri, Ray ray) {
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

    if(res.edge0 < 0.0 || res.edge1 + res.edge0 > 1.0 + eps) {
        return res;
    }

    res.distance = dot(tri.edge0, vertToOriginCrossEdge1) * inverseDet;

    res.hit = true;
    return res;
}


void main() {
    vec3 origin = vec3(0.0, 0.0, 0.0);
    vec3 dir = normalize(vec3(fragPos.x, fragPos.y, 1.0));
    Ray ray = Ray(origin, dir);

    Tri tri = Tri(vec3(0.0, 0.0, 2.0), vec3(1.0, 0.0, 0.0), vec3(0.0, 1.0, 0.0));
    Tri tri2 = Tri(vec3(2.0, 2.0, 3.0), vec3(0.0, -5.0, 0.0), vec3(-5.0, 0.0, 0.0));

    HitTestResult htr = hitTest(tri, ray);
    HitTestResult htr2 = hitTest(tri2, ray);

    vec4 color = vec4(vec3(0.0), 1.0);
    if(htr.hit) {
        color = vec4(htr.edge0, htr.edge1, 0.5, 1.0);
    }
    if(htr2.hit && (!htr.hit || htr2.distance < htr.distance)) {
        color = vec4(htr2.edge0, 0.5, htr2.edge1, 1.0);
    }

    gl_FragColor = color;
}

"""
