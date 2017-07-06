Shader.readDataSource = """
uniform sampler2D triangleBufferSampler;
uniform uint triangleBufferMask;
uniform uint triangleBufferShift;


uniform highp usampler2D octreeBufferSampler;
uniform uint octreeBufferMask;
uniform uint octreeBufferShift;


const uint triangleStride = 9u;
const uint octreeRootAddress = 0u;


ivec2 getTexelForAddress(uint address, uint mask, uint shift) {
    return ivec2(address & mask, address >> shift);
}


float readTriData(uint address) {
    return texelFetch(triangleBufferSampler, getTexelForAddress(
        address, triangleBufferMask, triangleBufferShift), 0).r;
}


uint readOctreeData(uint address) {
    return texelFetch(octreeBufferSampler, getTexelForAddress(
        address, octreeBufferMask, octreeBufferShift), 0).r;
}


Triangle readTri(uint address) {
    return Triangle(
        vec3(readTriData(address + 0u), readTriData(address + 1u), readTriData(address + 2u)),
        vec3(readTriData(address + 3u), readTriData(address + 4u), readTriData(address + 5u)),
        vec3(readTriData(address + 6u), readTriData(address + 7u), readTriData(address + 8u))
    );
}


Octree readOctree(uint address) {
    uint triStartAddress = readOctreeData(address + 0u);
    uint triEndAddress   = readOctreeData(address + 1u);
    uint loadFlag        = readOctreeData(address + 2u);

    // Check load flag
    if(loadFlag == 0u) {
        return Octree(triStartAddress, triEndAddress,
            uint[8](0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u));
    }

    return Octree(
        triStartAddress, triEndAddress,
        uint[8](
            readOctreeData(address + 3u),
            readOctreeData(address + 4u),
            readOctreeData(address + 5u),
            readOctreeData(address + 6u),
            readOctreeData(address + 7u),
            readOctreeData(address + 8u),
            readOctreeData(address + 9u),
            readOctreeData(address + 10u)
        )
    );
}

"""
