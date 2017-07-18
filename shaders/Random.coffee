ShaderSources.getRandomSource = -> """
float random(inout uint rngState) {
    vec3 seed = vec3(fragPos, float(rngState++));

    // Poor but somewhat useable RNG
    float x = sin(seed.x * 1000.0) + 2.0;
    float y = sin(seed.y * 1000.0 * x) + 2.0;
    float z = sin(seed.z * 1000.0 * x * y);
    return fract(x + y + z);
}


vec3 unitSphereRandom(inout uint rngState) {
    float theta = random(rngState) * 3.1415926 * 2.0;
    float phi   = acos(random(rngState) * 2.0 - 1.0);
    return vec3(cos(theta) * sin(phi), sin(theta) * sin(phi), cos(phi));
}


"""
