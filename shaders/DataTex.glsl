ivec2 getTexelForAddress(uint address, uvec2 maskAndShift) {
    return ivec2(address & maskAndShift.x, address >> maskAndShift.y);
}


// Triangle data loading functions
float readTriangleFloat(uint address) {
    return texelFetch(
        treeFloatBufferSampler,
        getTexelForAddress(address, treeFloatBufferAddrData),
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


// KDTree data loading functions
uint readKDTreeUint(uint address) {
    return texelFetch(
        treeUintBufferSampler,
        getTexelForAddress(address, treeUintBufferAddrData),
        0
    ).r;
}

KDTree readKDTree(uint address) {
    uint triangleStart = readKDTreeUint(address + 0u);
    uint triangleEnd   = readKDTreeUint(address + 1u);
    uint splitAxis     = readKDTreeUint(address + 2u);
    vec3 splitAxisVec  =
        (splitAxis == 0u) ? vec3(1.0, 0.0, 0.0) :
        (splitAxis == 1u) ? vec3(0.0, 1.0, 0.0) :
                            vec3(0.0, 0.0, 1.0);

    return KDTree(
        triangleStart,
        triangleEnd,
        uint[2](
            readKDTreeUint(address + 3u),
            readKDTreeUint(address + 4u)
        ),
        splitAxisVec,
        readTriangleFloat(triangleEnd),
        Box(
            readTriangleVec3(triangleEnd + 1u),
            readTriangleVec3(triangleEnd + 4u)
        )
    );
}


// Material data loading functions
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

MaterialTexData readMaterialTexData(uint address) {
    return MaterialTexData(
        readMaterialFloat(address + 0u),
        vec2(
            readMaterialFloat(address + 1u),
            readMaterialFloat(address + 2u)
        )
    );
}

Material readMaterial(uint address) {
    return Material(
        readMaterialFloat(   address + 0u),
        readMaterialVec3(    address + 1u),
        readMaterialVec3(    address + 4u),
        readMaterialVec3(    address + 7u),
        readMaterialTexData( address + 10u),
        readMaterialTexData( address + 13u),
        readMaterialTexData( address + 16u)
    );
}


// Random data loading function
float readRandomFloat(uint address) {
    return texelFetch(
        randomBufferSampler,
        getTexelForAddress(address, randomBufferAddrData),
        0
    ).r;
}
