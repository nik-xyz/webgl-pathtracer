Shader.fragShaderSource = """
#version 300 es

precision mediump float;

""" + Shader.typesSource   + """
""" + Shader.octreeSource  + """
""" + Shader.hitTestSource + """
""" + Shader.dataTexSource + """

in  vec2 fragPos;
out vec4 fragColor;


uniform float cullDistance;
uniform vec3 cameraPosition;

uniform Cube octreeCube;

const uint octreeStackSize = 10u;


struct SceneRayTraceResult {
    bool hit;
    vec3 pos;
    vec3 nor;
    vec2 tex;
};


struct StackElem {
    Octree node;
    Cube cube;
    uint execState;
};


SceneRayTraceResult rayTraceScene(Ray ray) {
    uint closestTriAddress;
    PosTriangle closestTri;
    HitTestResult closestHtr;
    closestHtr.distance = cullDistance;

    int stackIndex = 0;
    StackElem stack[octreeStackSize];

    #define stackTop (stack[stackIndex])

    // Push root node onto stack
    stackTop = StackElem(readOctree(octreeRootAddress), octreeCube, 0u);

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
                    stackTop = StackElem(readOctree(childAddress), childCube, 0u);

                    break;
                }
            }
        }

        // Test the current node's triangles
        if(stackTop.execState == 8u) {
            uint start = stackTop.node.triStartAddress;
            uint end   = stackTop.node.triEndAddress;

            for(uint addr = start; addr < end; addr += triangleStride) {
                PosTriangle tri = readTriPosData(addr);
                HitTestResult htr = hitTestTri(tri, ray);
                if(htr.hit && htr.distance < closestHtr.distance) {
                    closestHtr = htr;
                    closestTri = tri;
                    closestTriAddress = addr;
                }
            }

            // Pop node
            stackIndex--;
        }
    }

    #undef stackTop

    if(!closestHtr.hit) {
        SceneRayTraceResult res;
        res.hit = false;
        return res;
    }

    AuxTriangle auxTri = readTriAuxData(closestTriAddress);

    return SceneRayTraceResult(
        true,

        closestTri.vert +
        closestTri.edge0 * closestHtr.edge0 +
        closestTri.edge1 * closestHtr.edge1,

        auxTri.vertNor +
        auxTri.edge0Nor * closestHtr.edge0 +
        auxTri.edge1Nor * closestHtr.edge1,

        auxTri.vertTex +
        auxTri.edge0Tex * closestHtr.edge0 +
        auxTri.edge1Tex * closestHtr.edge1
    );
}


void main() {
    vec3 dir = normalize(vec3(fragPos.x, fragPos.y, 0.9));
    Ray ray = Ray(cameraPosition, dir, 1.0 / dir);

    SceneRayTraceResult res = rayTraceScene(ray);

    fragColor = vec4(res.nor, 1.0);
}

"""
