ShaderSources.getScatterSource = -> """
struct ScatterResult {
    // The direction of the scattered ray
    vec3 dir;

    // How much light will be transported along the scattered ray
    vec3 transportCoeff;
};


// Probabilistically scatters the ray using the scattering function
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
