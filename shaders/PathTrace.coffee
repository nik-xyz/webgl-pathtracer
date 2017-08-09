ShaderSources.getPathTraceSource = -> """
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

        if(shtr.hit) {
            // Load material from buffer
            Material material = readMaterial(shtr.materialIndex);

            // TODO: Move texture lookups sperate method

            vec2 texSize = vec2(textureSize(materialTexArraySampler, 0).xy);

            // Load diffuse texture if there is one
            if(material.diffuseTexData.x > -0.5) {
                // TODO: check texture orientation. The plane and ball seem to be
                // in conflict
                vec3 tex = vec3((vec2(1.0) - shtr.tex) * material.diffuseTexData.yz /
                    texSize.xy, material.diffuseTexData.x);
                material.diffuseMultiplier *= texture(materialTexArraySampler, tex).rgb;
            }

            // Load specular texture if there is one
            if(material.specularTexData.x > -0.5) {
                vec3 tex = vec3(shtr.tex * material.specularTexData.yz /
                    texSize.xy, material.specularTexData.x);
                material.diffuseMultiplier *= texture(materialTexArraySampler, tex).rgb;
            }

            // Load emission texture if there is one
            if(material.emissionTexData.x > -0.5) {
                vec3 tex = vec3(shtr.tex * material.emissionTexData.yz /
                    texSize.xy, material.emissionTexData.x);
                material.diffuseMultiplier *= texture(materialTexArraySampler, tex).rgb;
            }

            // Use scattering function to determine the new ray's direction
            ScatterResult sr = scatterMaterial(
                ray.dir, shtr.nor, material, rngState);

            ray = createRay(shtr.pos + sr.dir * RAY_SURFACE_OFFSET, sr.dir);

            // Accumulate emission from surface
            incomingLight += transportCoeff * material.emissionMultiplier;

            // Calculate the new overall transport coefficient using
            // with the current material's transport coefficient
            transportCoeff *= sr.transportCoeff;
        }
        else {
            // TODO: sample background enviroment map instead
            // For now, fake a square light
            vec3 backgroundLight = vec3(
                max(abs(ray.dir.x), abs(ray.dir.z)) < 0.4 && ray.dir.y > 0.0 ?
                    5.0 : 0.0
            );

            incomingLight += transportCoeff * backgroundLight;
            break;
        }
    }

    return incomingLight;
}


"""
