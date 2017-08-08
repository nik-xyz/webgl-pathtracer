ShaderSources.getMaterialSource = -> """
struct Material {
    float specularity;
    vec3 diffuseMultiplier;
    vec3 specularMultiplier;
    vec3 emissionMultiplier;

    float diffuseTexArrayIndex;
    float specularTexArrayIndex;
    float emissionTexArrayIndex;
};


"""
