ShaderSources.getKDTreeSource = -> """
struct KDTree {
    uint triStartAddress;
    uint triEndAddress;
    uint childAddresses[2];
    uint splitAxis;
    float splitPoint;
};


"""
