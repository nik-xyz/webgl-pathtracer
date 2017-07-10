Shader.sceneHitTestSource = """
const uint SCENE_OCTREE_ROOT_ADDRESS = 0u;
const uint OCTREE_STACK_SIZE = 10u;
const float RAY_CUTOFF_DISTANCE = 100000.0;


struct SceneHitTestResult {
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


// Define convenient reference to the top of the stack
#ifdef stackTop
#error stackTop is already defined
#endif
#define stackTop (stack[stackIndex])


SceneHitTestResult hitTestScene(Ray ray) {
    // Store the closest triangle intersected so far
    uint closestTriAddress;
    TrianglePosData closestTri;
    TriangleHitTestResult closestHtr;
    closestHtr.distance = RAY_CUTOFF_DISTANCE;

    // Octree traversal stack
    int stackIndex = 0;
    StackElem stack[OCTREE_STACK_SIZE];

    // Push root node onto stack
    stackTop = StackElem(
        readOctree(SCENE_OCTREE_ROOT_ADDRESS),
        Cube(octreeCubeCenter, octreeCubeSize),
        0u
    );

    // Traverse octree
    while(stackIndex >= 0) {
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
            for(uint addr = stackTop.node.triStartAddress;
                addr < stackTop.node.triEndAddress;
                addr += TRIANGLE_STRIDE
            ) {
                TrianglePosData tri = readTriPosData(addr);
                TriangleHitTestResult htr = hitTestTri(tri, ray);

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

    if(!closestHtr.hit) {
        SceneHitTestResult res;
        res.hit = false;
        return res;
    }

    TriangleAuxAttribs closestTriAux = readTriAuxData(closestTriAddress);

    return SceneHitTestResult(
        true,

        closestTri.vert +
        closestTri.edge0 * closestHtr.edge0 +
        closestTri.edge1 * closestHtr.edge1,

        closestTriAux.vertNor +
        closestTriAux.edge0Nor * closestHtr.edge0 +
        closestTriAux.edge1Nor * closestHtr.edge1,

        closestTriAux.vertTex +
        closestTriAux.edge0Tex * closestHtr.edge0 +
        closestTriAux.edge1Tex * closestHtr.edge1
    );
}

#undef stackTop
"""
