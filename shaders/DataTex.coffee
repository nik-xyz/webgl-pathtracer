ShaderSources.getDataTexSource = -> """
ivec2 getTexelForAddress(uint address, uvec2 maskAndShift) {
    return ivec2(address & maskAndShift.x, address >> maskAndShift.y);
}



// ---- Triangle ----
float readTriangleFloat(uint address) {
    return texelFetch(
        triangleBufferSampler,
        getTexelForAddress(address, triangleBufferAddrData),
        0
    ).r;
}


vec2 readTriangleVec2(uint address) {
    return vec2(
        readTriangleFloat(address + 0u),
        readTriangleFloat(address + 1u)
    );
}


vec3 readTriangleVec3(uint address) {
    return vec3(
        readTriangleFloat(address + 0u),
        readTriangleFloat(address + 1u),
        readTriangleFloat(address + 2u)
    );
}


TrianglePositions readTrianglePositions(uint address) {
    return TrianglePositions(
        readTriangleVec3(address + 0u),
        readTriangleVec3(address + 3u),
        readTriangleVec3(address + 6u)
    );
}


TriangleAuxAttribs readTriangleAuxAttribs(uint address) {
    return TriangleAuxAttribs(
        readTriangleVec3(address + 9u),
        readTriangleVec3(address + 12u),
        readTriangleVec3(address + 15u),
        readTriangleVec2(address + 18u),
        readTriangleVec2(address + 20u),
        readTriangleVec2(address + 22u),
        uint(round(readTriangleFloat(address + 24u)))
    );
}



// ---- Octree ----
uint readOctreeUint(uint address) {
    return texelFetch(
        octreeBufferSampler,
        getTexelForAddress(address, octreeBufferAddrData),
        0
    ).r;
}


Octree readOctree(uint address) {
    uint triStartAddress = readOctreeUint(address + 0u);
    uint triEndAddress   = readOctreeUint(address + 1u);
    uint loadFlag        = readOctreeUint(address + 2u);

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
            readOctreeUint(address + 3u),
            readOctreeUint(address + 4u),
            readOctreeUint(address + 5u),
            readOctreeUint(address + 6u),
            readOctreeUint(address + 7u),
            readOctreeUint(address + 8u),
            readOctreeUint(address + 9u),
            readOctreeUint(address + 10u)
        )
    );
}



// ---- Material ----
float readMaterialFloat(uint address) {
    return texelFetch(
        materialBufferSampler,
        getTexelForAddress(address, materialBufferAddrData),
        0
    ).r;
}


vec3 readMaterialVec3(uint address) {
    return vec3(
        readMaterialFloat(address + 0u),
        readMaterialFloat(address + 1u),
        readMaterialFloat(address + 2u)
    );
}


Material readMaterial(uint address) {
    return Material(
        readMaterialVec3( address + 0u),
        readMaterialFloat(address + 3u),
        readMaterialVec3( address + 4u),
        readMaterialVec3( address + 7u)
    );
}



// ---- Random data ----
float readRandomFloat(uint address) {
    return texelFetch(
        randomBufferSampler,
        getTexelForAddress(address, randomBufferAddrData),
        0
    ).r;
}


"""
