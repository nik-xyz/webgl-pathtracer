ShaderSources.getScatterSource = -> """
struct ScatterResult {
    // The direction of the scattered ray
    vec3 dir;

    // How much light will be transported along the scattered ray
    vec3 transportCoeff;
};


// Probabilistically scatters the ray according to the Lambertian distribution.
vec3 scatterLambertian(vec3 normal, inout uint rngState) {
    vec3 spherePoint = unitSphereRandom(rngState);
    vec3 hemispherePoint = dot(normal, spherePoint) < 0.0 ?
        -spherePoint : spherePoint;

    float lengthAlongNormal = dot(hemispherePoint, normal);
    float remappedLength = sqrt(lengthAlongNormal);

    vec3 planeVec = normalize(hemispherePoint - normal * lengthAlongNormal);
    float remappedPlaneLength = sqrt(1.0 - pow(remappedLength, 2.0));
    return normal * remappedLength + planeVec * remappedPlaneLength;
}


// Probabilistically scatters the ray using the scattering function
// defined by the given material
ScatterResult scatterMaterial(
    vec3 incident, vec3 normal,
    Material material, inout uint rngState
) {
    ScatterResult res;

    if(random(rngState) < material.specularity) {
        res.dir = reflect(incident, normal);
        res.transportCoeff = material.specularMultiplier;
    }
    else {
        res.dir = scatterLambertian(normal, rngState);
        res.transportCoeff = material.diffuseMultiplier;
    }

    return res;
}


"""
