Shader.fragShaderSource = """
#version 300 es

precision mediump float;

""" + Shader.typesSource + """
""" + Shader.hitTestSource + """
""" + Shader.readDataSource + """

in  vec2 fragPos;
out vec4 fragColor;


uniform float cullDistance;
uniform vec3 cameraPosition;

uniform Cube octreeCube;

const uint octreeStackSize = 10u;


Cube getOctreeChildCube(Cube parentCube, uint index) {
    vec3 bits = vec3((index >> 2u) & 1u, (index >> 1u) & 1u, (index >> 0u) & 1u);
    return Cube(
        (bits - 0.5) * parentCube.size * 0.5 + parentCube.center,
        parentCube.size * 0.5
    );
}


vec4 rayTraceScene(Ray ray) {
    Triangle closestTri;
    HitTestResult closestHtr;
    closestHtr.distance = cullDistance;

    int stackIndex = 0;
    struct StackElem {
        Octree node;
        Cube cube;
        uint execState;
    } stack[octreeStackSize];

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
                Triangle tri = readTri(addr);
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
