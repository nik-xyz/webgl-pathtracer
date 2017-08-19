ShaderSources.getKDTreeSource = () => `
struct KDTree {
    uint triStartAddress;
    uint triEndAddress;
    uint childAddresses[2];
    vec3 splitAxis;
    float splitPoint;
    Box box;
};
`;
