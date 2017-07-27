ShaderSources.getMaterialSource = -> """
struct Material {
    vec3 emissivity;

    float specularity;
    vec3 specularReflectivity;
    vec3 diffuseReflectivity;
};


"""
