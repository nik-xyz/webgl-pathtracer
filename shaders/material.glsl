const uint DIFFUSE_TEXTURE_BIT  = 1u << 0u;
const uint SPECULAR_TEXTURE_BIT = 1u << 1u;
const uint EMISSION_TEXTURE_BIT = 1u << 2u;

struct Material {
    // Determines the probabbility that the specular scattering function
    // will be chosen instead of the Lambertian scattering function.
    float specularity;

    // Indicates whether there are textures for the diffuse, specular,
    // and emission components of the material
    uint textureBitfield;

    // If the texture bitfeild indicates that a texture should be used, these
    // vectors store imformation about the texture, otherwise they store the
    // color that should be used instead.
    vec3 diffuse;
    vec3 specular;
    vec3 emission;
};

vec3 getMaterialArrayTexCoords(vec2 texCoord, vec3 data) {
    vec2 texSize = vec2(textureSize(materialTexArraySampler, 0).xy);
    return vec3(texCoord * data.yz / texSize, data.x);
}

vec3 getMaterialDiffuseValue(Material material, vec2 tex) {
    if((material.textureBitfield & DIFFUSE_TEXTURE_BIT) == 0u) {
        return material.diffuse;
    }
    vec3 arrayTexCoord = getMaterialArrayTexCoords(tex, material.diffuse);
    return texture(materialTexArraySampler, arrayTexCoord).rgb;
}

vec3 getMaterialSpecularValue(Material material, vec2 tex) {
    if((material.textureBitfield & SPECULAR_TEXTURE_BIT) == 0u) {
        return material.specular;
    }
    vec3 arrayTexCoord = getMaterialArrayTexCoords(tex, material.specular);
    return texture(materialTexArraySampler, arrayTexCoord).rgb;
}

vec3 getMaterialEmissionValue(Material material, vec2 tex) {
    if((material.textureBitfield & EMISSION_TEXTURE_BIT) == 0u) {
        return material.emission;
    }
    vec3 arrayTexCoord = getMaterialArrayTexCoords(tex, material.emission);
    return texture(materialTexArraySampler, arrayTexCoord).rgb;
}
