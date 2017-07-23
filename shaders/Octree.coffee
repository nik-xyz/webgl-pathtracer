ShaderSources.getOctreeSource = -> """
struct Octree {
    uint triStartAddress;
    uint triEndAddress;
    uint childAddresses[8];
};


Cube getOctreeChildCube(Cube parentCube, uint index) {
    vec3 bits = vec3(
        (index >> 2u) & 1u,
        (index >> 1u) & 1u,
        (index >> 0u) & 1u
    );

    return Cube(
        (bits - 0.5) * parentCube.size + parentCube.center,
        parentCube.size * 0.5
    );
}


"""
