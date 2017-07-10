Shader.readDataSource = """
uniform sampler2D triangleBufferSampler;
uniform uint triangleBufferMask;
uniform uint triangleBufferShift;


uniform highp usampler2D octreeBufferSampler;
uniform uint octreeBufferMask;
uniform uint octreeBufferShift;


const uint triangleStride = 24u;
const uint octreeRootAddress = 0u;


ivec2 getTexelForAddress(uint address, uint mask, uint shift) {
    return ivec2(address & mask, address >> shift);
}


float readTriData(uint address) {
    return texelFetch(triangleBufferSampler, getTexelForAddress(
        address, triangleBufferMask, triangleBufferShift), 0).r;
}


vec3 readTriVec3Data(uint address) {
    return vec3(
        readTriData(address + 0u),
        readTriData(address + 1u),
        readTriData(address + 2u)
    );
}


vec2 readTriVec2Data(uint address) {
    return vec2(
        readTriData(address + 0u),
        readTriData(address + 1u)
    );
}


uint readOctreeData(uint address) {
    return texelFetch(octreeBufferSampler, getTexelForAddress(
        address, octreeBufferMask, octreeBufferShift), 0).r;
}


PosTriangle readTriPosData(uint address) {
    return PosTriangle(
        readTriVec3Data(address + 0u),
        readTriVec3Data(address + 3u),
        readTriVec3Data(address + 6u)
    );
}


AuxTriangle readTriAuxData(uint address) {
    return AuxTriangle(
        readTriVec3Data(address + 9u),
        readTriVec3Data(address + 12u),
        readTriVec3Data(address + 15u),
        readTriVec2Data(address + 18u),
        readTriVec2Data(address + 20u),
        readTriVec2Data(address + 22u)
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
