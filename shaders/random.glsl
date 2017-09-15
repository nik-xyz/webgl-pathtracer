// Must match RANDOM_DATA_LENGTH in random-gen.js
uint RANDOM_DATA_LENGTH = 1u << 12u;


uint cantorPairing(uvec2 pair) {
    uint sum = pair.x + pair.y;
    return (sum * (sum + 1u)) / 2u + pair.y;
}


float random(inout uint rngState) {
    // Doesn't work well near zero, so bias it
    uvec2 coord = uvec2(gl_FragCoord) + uvec2(10u, 10u);

    // Need to reduce 2D coordinate to 1D seed. Cantor's pairing function works
    // well because both dimensions have a similar affect on the output, which
    // avoids anisotropic patterns if it is used carefully.
    uint addr = cantorPairing(coord);

    // Mix it up a bit further
    addr = cantorPairing(uvec2(addr, coord.x * coord.y));

    // Use quadratic probing to ensure that similar values of addr
    // don't generate overlapping sequences.
    addr += rngState * rngState;

    // Compute the address mod the buffer length. The buffer length is a power of
    // two, so the value can be computed quickly with a bitmask.
    addr = addr & (RANDOM_DATA_LENGTH - 1u);

    rngState += 1u;

    return readRandomFloat(addr);
}


vec3 unitSphereRandom(inout uint rngState) {
    float theta = random(rngState) * 3.1415926 * 2.0;
    float phi   = acos(random(rngState) * 2.0 - 1.0);
    return vec3(cos(theta) * sin(phi), sin(theta) * sin(phi), cos(phi));
}
