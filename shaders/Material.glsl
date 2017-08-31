struct MaterialTexData {
    float layer;
    vec2 size;
};

struct Material {
    float specularity;

    vec3 diffuseCoeff;
    vec3 specularCoeff;
    vec3 emissionCoeff;

    MaterialTexData diffuseTex;
    MaterialTexData specularTex;
    MaterialTexData emissionTex;
};

vec3 getMaterialArrayTexCoords(vec2 texCoord, MaterialTexData data) {
    vec2 texSize = vec2(textureSize(materialTexArraySampler, 0).xy);
    return vec3(texCoord * data.size / texSize, data.layer);
}

vec3 getMaterialDiffuseValue(Material material, vec2 tex) {
    if(material.diffuseTex.layer < -0.5) {
        return material.diffuseCoeff;
    }

    return material.diffuseCoeff * texture(materialTexArraySampler,
        getMaterialArrayTexCoords(tex, material.diffuseTex)).rgb;
}

vec3 getMaterialSpecularValue(Material material, vec2 tex) {
    if(material.specularTex.layer < -0.5) {
        return material.specularCoeff;
    }

    return material.specularCoeff * texture(materialTexArraySampler,
        getMaterialArrayTexCoords(tex, material.specularTex)).rgb;
}

vec3 getMaterialEmissionValue(Material material, vec2 tex) {
    if(material.emissionTex.layer < -0.5) {
        return material.emissionCoeff;
    }

    return material.emissionCoeff * texture(materialTexArraySampler,
        getMaterialArrayTexCoords(tex, material.emissionTex)).rgb;
}
