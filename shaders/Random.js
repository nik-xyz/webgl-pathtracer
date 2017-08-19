ShaderSources.getRandomSource = () => `
uint RANDOM_DATA_LENGTH = ${RandomGen.RANDOM_DATA_LENGTH}u;


uint cantorPairing(uvec2 pair) {
    uint sum = pair.x + pair.y;
    return (sum * (sum + 1u)) / 2u + pair.y;
}


float random(inout uint rngState) {
    uvec2 coord = uvec2(gl_FragCoord);

    // Combine the coordinates and seed using Cantor's pairing
    // function, which avoids noticeable patterns in the end result.
    uint addr = cantorPairing(coord);
    addr = cantorPairing(uvec2(addr, coord.x * coord.y));
    addr = cantorPairing(uvec2(addr, rngState));
    addr = addr & (RANDOM_DATA_LENGTH - 1u);

    rngState += 1u;

    return readRandomFloat(addr);
}


vec3 unitSphereRandom(inout uint rngState) {
    float theta = random(rngState) * 3.1415926 * 2.0;
    float phi   = acos(random(rngState) * 2.0 - 1.0);
    return vec3(cos(theta) * sin(phi), sin(theta) * sin(phi), cos(phi));
}
`;
