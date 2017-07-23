ShaderSources.getPathTraceSource = -> """
// Ray bounce limit
const uint BOUNCES = 5u;

const float RAY_SURFACE_OFFSET = 0.001;


// Defines the scattering function for the surface
vec3 scatter(vec3 incident, vec3 normal, inout uint rngState) {
    float specularity = 0.2;

    if(random(rngState) < specularity) {
        // Specular reflection
        return reflect(incident, normal);
    }
    else {
        // Calculate lambertian distribution
        // FIXME
        return normalize(normal + unitSphereRandom(rngState));
    }
}


vec3 tracePath(Ray ray, inout uint rngState) {
    // Accumulates the total light along the path
    vec3 incomingLight = vec3(0.0);

    // How much of the incoming light from the current ray will be transported
    // to the original ray's origin along the path that has been traced so far
    vec3 transportCoeff = vec3(1.0);

    for(uint bounce = 0u; bounce < BOUNCES; bounce++) {
        SceneHitTestResult htr = hitTestScene(ray);

        if(htr.hit) {
            // TODO: get emissivity from material
            vec3 emittedLight = vec3(0.0);

            // Accumulate emission from surface
            incomingLight += transportCoeff * emittedLight;

            // TODO: Get reflectivity / transmissivity from material
            // TODO: Use Different coeffs for different scattering functions
            vec3 materialTransportCoeff = vec3(htr.tex.y, htr.tex.y, 1.0);

            // Calculate the new overall transport coefficient using
            // with the current material's transport coefficient
            transportCoeff *= materialTransportCoeff;

            // Use scattering function to determine the new ray's direction
            vec3 dir = scatter(ray.dir, htr.nor, rngState);
            ray = createRay(htr.pos + dir * RAY_SURFACE_OFFSET, dir);
        }
        else {
            // TODO: sample background enviroment map instead
            vec3 backgroundLight = vec3(ray.dir.yyy + 0.3);

            incomingLight += transportCoeff * backgroundLight;
            break;
        }
    }

    return incomingLight;
}


"""
