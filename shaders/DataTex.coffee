ShaderSources.getDataTexSource = -> """
ivec2 getTexelForAddress(uint address, uvec2 maskAndShift) {
    return ivec2(address & maskAndShift.x, address >> maskAndShift.y);
}


float readRandomData(uint address) {
    return texelFetch(
        randomBufferSampler,
        getTexelForAddress(address, randomBufferAddrData),
        0
    ).r;
}


float readTriData(uint address) {
    return texelFetch(
        triangleBufferSampler,
        getTexelForAddress(address, triangleBufferAddrData),
        0
    ).r;
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
    return texelFetch(
        octreeBufferSampler,
        getTexelForAddress(address, octreeBufferAddrData),
        0
    ).r;
}


TrianglePosData readTriPosData(uint address) {
    return TrianglePosData(
        readTriVec3Data(address + 0u),
        readTriVec3Data(address + 3u),
        readTriVec3Data(address + 6u)
    );
}


TriangleAuxAttribs readTriAuxData(uint address) {
    return TriangleAuxAttribs(
        readTriVec3Data(address + 9u),
        readTriVec3Data(address + 12u),
        readTriVec3Data(address + 15u),
        readTriVec2Data(address + 18u),
        readTriVec2Data(address + 20u),
        readTriVec2Data(address + 22u),
        uint(round(readTriData(address + 24u)))
    );
}


Octree readOctree(uint address) {
    uint triStartAddress = readOctreeData(address + 0u);
    uint triEndAddress   = readOctreeData(address + 1u);
    uint loadFlag        = readOctreeData(address + 2u);

    // Check load flag
    if(loadFlag == 0u) {
        return Octree(
            triStartAddress,
            triEndAddress,
            uint[8](0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u)
        );
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
