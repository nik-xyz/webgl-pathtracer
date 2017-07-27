class Material
    constructor: (
        @emissivity,
        @specularity,
        @specularReflectivity,
        @diffuseReflectivity
    ) ->


    encode: -> [
            @emissivity.array()
            [@specularity]
            @specularReflectivity.array()
            @diffuseReflectivity.array()
        ].reduce((a, b) -> a.concat(b))
