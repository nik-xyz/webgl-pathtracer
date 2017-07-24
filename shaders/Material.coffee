ShaderSources.getMaterialSource = -> """

struct Material {
    vec3 emissivity;

    float specularity;
    vec3 specularReflectivity;
    vec3 diffuseReflectivity;
};


struct ScatterResult {
    vec3 dir;
    vec3 transportCoeff;
};


// Probabilistically scatters ray using the scattering function
// defined by the given material
ScatterResult scatterMaterial(
    vec3 incident, vec3 normal,
    Material material, inout uint rngState
) {
    ScatterResult res;

    if(random(rngState) < material.specularity) {
        // Specular reflection
        res.dir = reflect(incident, normal);
        res.transportCoeff = material.specularReflectivity;
    }
    else {
        // FIXME: Calculate lambertian distribution
        res.dir = normalize(normal + unitSphereRandom(rngState));
        res.transportCoeff = material.diffuseReflectivity;
    }

    return res;
}


"""
