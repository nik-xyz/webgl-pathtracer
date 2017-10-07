const uint BOUNCE_LIMIT = 5u;

const float RAY_SURFACE_OFFSET = 0.001;


vec3 tracePath(Ray ray, inout uint rngState) {
    // Accumulates the total light along the path
    vec3 incomingLight = vec3(0.0);

    // How much of the incoming light from the current ray will be transported
    // to the original ray's origin along the path that has been traced so far
    vec3 transportCoeff = vec3(1.0);

    for(uint bounce = 0u; bounce < BOUNCE_LIMIT; bounce++) {
        SceneHitTestResult shtr = hitTestScene(ray);

        if(!shtr.hit) {
            // TODO: sample background enviroment map.
            float angle = acos(ray.dir.y) / 3.141592 * 2.0;

            // Very poor approximation
            vec3 sun = vec3(1.0, 0.9, 0.7) * 1.4 * smoothstep(0.0, 1.0, max(1.0 - angle * 6.0, 0.0));
            vec3 sky = vec3(0.64, 0.75, 1.0) * (1.3 - angle * 0.2);

            incomingLight += transportCoeff * vec3(sky + sun);
            break;
        }

        // Load material from buffer
        Material material = readMaterial(shtr.materialIndex);

        // Use scattering function to determine the new ray's direction
        ScatterResult sr = scatterMaterial(ray.dir, shtr.nor, shtr.tex, material, rngState);

        // Accumulate emission from surface
        incomingLight += transportCoeff * getMaterialEmissionValue(material, shtr.tex);

        // Calculate the new overall transport coefficient using
        // with the current material's transport coefficient
        transportCoeff *= sr.transportCoeff;

        // Project scattered ray into scene for the next iteration
        ray = createRay(shtr.pos + sr.dir * RAY_SURFACE_OFFSET, sr.dir);
    }

    return incomingLight;
}
