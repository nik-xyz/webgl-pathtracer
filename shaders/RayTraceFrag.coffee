RayTracer.fragShaderSource = """
#version 300 es

precision mediump float;

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


in  vec2 fragPos;
out vec4 fragColor;


uniform float cullDistance;
uniform vec3 cameraPosition;

uniform Cube octreeCube;

uniform sampler2D triangleBufferSampler;
uniform uint triangleBufferMask;
uniform uint triangleBufferShift;

uniform highp usampler2D octreeBufferSampler;
uniform uint octreeBufferMask;
uniform uint octreeBufferShift;

const uint nodeStackSize = 10u;
const uint triangleStride = 3u;
const uint octreeRootAddress = 0u;


ivec2 getTexelForAddress(uint address, uint mask, uint shift) {
    return ivec2(address & mask, address >> shift);
}


vec3 readTriData(uint address) {
    return texelFetch(triangleBufferSampler, getTexelForAddress(
        address, triangleBufferMask, triangleBufferShift), 0).rgb;
}


uvec4 readOctreeData(uint address) {
    return texelFetch(octreeBufferSampler, getTexelForAddress(
        address, octreeBufferMask, octreeBufferShift), 0);
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
    uvec4 octreeData0 = uvec4(0u);
    uvec4 octreeData1 = uvec4(0u);

    // Check load flag
    if(triangleData[2] != 0u) {
        octreeData0 = readOctreeData(address + 1u);
        octreeData1 = readOctreeData(address + 2u);
    }

    return Octree(
        triangleData.x, triangleData.y,
        uint[8](
            octreeData0[0], octreeData0[1], octreeData0[2], octreeData0[3],
            octreeData1[0], octreeData1[1], octreeData1[2], octreeData1[3]
        )
    );
}


Cube getOctreeChildCube(Cube parentCube, uint index) {
    vec3 bits = vec3((index >> 2u) & 1u, (index >> 1u) & 1u, (index >> 0u) & 1u);
    return Cube(
        (bits - 0.5) * parentCube.size * 0.5 + parentCube.center,
        parentCube.size * 0.5
    );
}


HitTestResult hitTestTri(Tri tri, Ray ray) {
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


float vec3Min(vec3 vec) {
    return min(vec.x, min(vec.y, vec.z));
}


float vec3Max(vec3 vec) {
    return max(vec.x, max(vec.y, vec.z));
}


bool hitTestCube(Cube cube, Ray ray) {
    vec3 originToCenter = cube.center - ray.origin;
    vec3 vert0 = (originToCenter - cube.size) * ray.inverseDir;
    vec3 vert1 = (originToCenter + cube.size) * ray.inverseDir;
    return vec3Min(max(vert0, vert1)) >= vec3Max(min(vert0, vert1));
}


vec4 rayTraceScene(Ray ray) {
    Tri closestTri;
    HitTestResult closestHtr;
    closestHtr.distance = cullDistance;

    int stackIndex = 0;
    struct {
        Octree node;
        Cube cube;
        uint execState;
    } stack[nodeStackSize];

    #define stackTop (stack[stackIndex])

    // Push root node onto stack
    stackTop.node = readOctree(octreeRootAddress);
    stackTop.cube = octreeCube;
    stackTop.execState = 0u;

    // Watchdog counter
    uint wd = 10000u;

    while(stackIndex >= 0 && wd > 0u) {
        wd--;

        // Find child octree nodes to test
        while(stackTop.execState < 8u) {
            uint childIndex = stackTop.execState;
            uint childAddress = stackTop.node.childAddresses[childIndex];
            stackTop.execState++;

            // Check that the child exists
            if(childAddress != 0u) {
                Cube childCube = getOctreeChildCube(stackTop.cube, childIndex);

                if(hitTestCube(stackTop.cube, ray)) {
                    stackIndex++;
                    stackTop.node = readOctree(childAddress);
                    stackTop.cube = childCube;
                    stackTop.execState = 0u;

                    break;
                }
            }
        }

        // Test the current node's triangles
        if(stackTop.execState == 8u) {
            uint start = stackTop.node.triStartAddress;
            uint end   = stackTop.node.triEndAddress;

            for(uint addr = start; addr < end; addr += triangleStride) {
                Tri tri = readTri(addr);
                HitTestResult htr = hitTestTri(tri, ray);
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
    Ray ray = Ray(cameraPosition, dir, 1.0 / dir);

    fragColor = rayTraceScene(ray);
}

"""
