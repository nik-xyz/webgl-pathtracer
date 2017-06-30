RayTracer.fragShaderSource = """
#version 300 es

precision mediump float;

in  vec2 fragPos;
out vec4 fragColor;


uniform float cullDistance;
uniform vec3 cameraPosition;


uniform sampler2D triangleBufferSampler;
uniform uint triangleBufferMask;
uniform uint triangleBufferShift;

uniform highp usampler2D octreeBufferSampler;
uniform uint octreeBufferMask;
uniform uint octreeBufferShift;


const uint nodeStackSize = 10u;
const uint triangleStride = 3u;
const uint octreeRootAddress = 0u;


struct Octree {
    uint triStartAddress;
    uint triEndAddress;
    uint childAddresses[8];
};


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


vec3 readTriData(uint address) {
    // Map address to 2D texel
    ivec2 texelCoord = ivec2(
        address &  triangleBufferMask,
        address >> triangleBufferShift
    );
    return texelFetch(triangleBufferSampler, texelCoord, 0).rgb;
}


uvec4 readOctreeData(uint address) {
    // Map address to 2D texel
    ivec2 texelCoord = ivec2(
        address &  octreeBufferMask,
        address >> octreeBufferShift
    );
    return texelFetch(octreeBufferSampler, texelCoord, 0);
}


Tri readTri(uint address) {
    return Tri(
        readTriData(address + 0u),
        readTriData(address + 1u),
        readTriData(address + 2u)
    );
}


Octree readOctree(uint address) {
    uvec4 triangleData = readOctreeData(address + 0u);
    uvec4 octreeData0  = readOctreeData(address + 1u);
    uvec4 octreeData1  = readOctreeData(address + 2u);

    return Octree(
        triangleData.x, triangleData.y,
        uint[8](
            octreeData0.x, octreeData0.y, octreeData0.z, octreeData0.w,
            octreeData1.x, octreeData1.y, octreeData1.z, octreeData1.w
        )
    );
}


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


vec4 rayTraceScene(Ray ray) {
    Tri closestTri;
    HitTestResult closestHtr;
    closestHtr.distance = cullDistance;

    int stackIndex = 0;
    struct {
        // The node being processed
        Octree node;

        // How far the node has been processed
        uint execState;
    } stack[nodeStackSize];

    #define stackTop (stack[stackIndex])

    // Push root node onto stack
    stackTop.node = readOctree(octreeRootAddress);
    stackTop.execState = 0u;

    // Watchdog counter
    uint wd = 1000u;

    while(stackIndex >= 0 && wd > 0u) {
        wd--;

        // Find child octree nodes to test
        while(stackTop.execState < 8u) {
            uint childAddress = stackTop.node.childAddresses[stackTop.execState];
            stackTop.execState++;

            // Push child node onto stack if it is valid
            if(childAddress != 0u) {
                stackIndex++;
                stackTop.node = readOctree(childAddress);
                stackTop.execState = 0u;
                break;
            }
        }

        // Test the current node's triangles
        if(stackTop.execState == 8u) {
            uint start = stackTop.node.triStartAddress;
            uint end   = stackTop.node.triEndAddress;

            for(uint addr = start; addr < end; addr += triangleStride) {
                Tri tri = readTri(addr);
                HitTestResult htr = hitTest(tri, ray);
                if(htr.hit && htr.distance < closestHtr.distance) {
                    closestHtr = htr;
                    closestTri = tri;
                }
            }

            // Pop node
            stackIndex--;
        }
    }

    #undef stackTop


    if(!closestHtr.hit) {
        return vec4(0.0, 0.0, 0.0, 1.0);
    }

    return vec4(closestHtr.edge0, closestHtr.edge1, 1.0, 1.0);
}


void main() {
    vec3 dir = normalize(vec3(fragPos.x, fragPos.y, 0.9));
    Ray ray = Ray(cameraPosition, dir);

    fragColor = rayTraceScene(ray);
}

"""
