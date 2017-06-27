RayTracer.fragShaderSource = """
precision mediump float;
varying vec2 fragPos;


uniform sampler2D floatBuffer;


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


vec3 readData(int address) {
    if(address == 0) return vec3(0.0, 0.0, 2.0);
    if(address == 1) return vec3(1.0, 0.0, 0.0);
    if(address == 2) return vec3(0.0, 1.0, 0.0);
    if(address == 3) return vec3(1.0, 1.0, 3.0);
    if(address == 4) return vec3(-3.0, 0.0, 0.0);
    if(address == 5) return vec3(0.0, -3.0, 0.0);

    return vec3(0.0);
}


Tri readTri(int address) {
    return Tri(readData(address), readData(address + 1), readData(address + 2));
}


vec4 rayTraceScene(Ray ray) {
    const int triLimit = 6;

    // TODO: make uniform
    const float cullDistance = 10000.0;

    HitTestResult closestHit;
    closestHit.distance = cullDistance;
    Tri closestTri;

    for(int addr = 0; addr < triLimit; addr += 3) {
        Tri tri = readTri(addr);

        HitTestResult htr = hitTest(tri, ray);
        if(htr.hit && htr.distance < closestHit.distance) {
            closestHit = htr;
            closestTri = tri;
        }
    }

    if(!closestHit.hit) {
        return vec4(0.0, 0.0, 0.0, 1.0);
    }

    return vec4(closestHit.edge0, closestHit.edge1, 1.0, 1.0);
}


void main() {
    vec3 origin = vec3(0.0, 0.0, 0.0);
    vec3 dir = normalize(vec3(fragPos.x, fragPos.y, 1.0));
    Ray ray = Ray(origin, dir);

    gl_FragColor = rayTraceScene(ray);
}

"""
