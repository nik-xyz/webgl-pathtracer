ShaderSources.getSceneHitTestSource = -> """
const uint SCENE_KDTREE_ROOT_ADDRESS = 0u;
const uint KDTREE_STACK_SIZE = #{(KDTree.SUBDIVISION_LIMIT + 1).toString()}u;
const float RAY_CUTOFF_DISTANCE = 100000.0;


struct SceneHitTestResult {
    bool hit;
    vec3 pos;
    vec3 nor;
    vec2 tex;
    uint materialIndex;
};


struct StackElem {
    KDTree node;
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
    TrianglePositions closestTri;
    TriangleHitTestResult closestThtr;
    closestThtr.hit = false;
    closestThtr.distance = RAY_CUTOFF_DISTANCE;

    // KDTree traversal stack
    int stackIndex = 0;
    StackElem stack[KDTREE_STACK_SIZE];

    // Push root node onto stack
    stackTop = StackElem(
        readKDTree(SCENE_KDTREE_ROOT_ADDRESS),
        0u
    );

    // Traverse tree
    while(stackIndex >= 0) {
        // Find child tree nodes to test
        while(stackTop.execState < 2u) {

            // TODO: pick the closest side first
            uint childIndex = stackTop.execState;

            uint childAddress = stackTop.node.childAddresses[childIndex];
            stackTop.execState++;

            // Push the child onto the stack if it exists
            if(childAddress != 0u) {
                // TODO: check whether ray intersects plane first

                stackIndex++;
                stackTop = StackElem(readKDTree(childAddress), 0u);

                break;
            }
        }

        // Test the current node's triangles
        if(stackTop.execState == 2u) {
            for(
                uint addr = stackTop.node.triStartAddress;
                addr < stackTop.node.triEndAddress;
                addr += TRIANGLE_STRIDE
            ) {
                TrianglePositions tri = readTrianglePositions(addr);
                TriangleHitTestResult thtr = hitTestTriangle(tri, ray);

                if(thtr.hit && thtr.distance < closestThtr.distance) {
                    closestThtr = thtr;
                    closestTri = tri;
                    closestTriAddress = addr;
                }
            }

            // Pop node
            stackIndex--;
        }
    }

    if(!closestThtr.hit) {
        SceneHitTestResult res;
        res.hit = false;
        return res;
    }

    TriangleAuxAttribs closestTriAux = readTriangleAuxAttribs(closestTriAddress);

    return SceneHitTestResult(
        // Hit
        true,

        // Position
        closestTri.vert +
        closestTri.edge0 * closestThtr.edge0 +
        closestTri.edge1 * closestThtr.edge1,

        // Normal
        normalize(
            closestTriAux.vertNor +
            closestTriAux.edge0Nor * closestThtr.edge0 +
            closestTriAux.edge1Nor * closestThtr.edge1
        ),

        // Texture coordinate
        closestTriAux.vertTex +
        closestTriAux.edge0Tex * closestThtr.edge0 +
        closestTriAux.edge1Tex * closestThtr.edge1,

        // Material index
        closestTriAux.materialIndex
    );
}

#undef stackTop


"""
