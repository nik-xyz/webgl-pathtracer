class Material
    # TODO: extend the material definition to include:
    # - flags to indicate whether diffuse and specular textures are to be used
    # - diffuse texture coords
    # - specular texture coords
    constructor: (
        @emissivity,
        @specularity,
        @specularReflectivity,
        @diffuseReflectivity
    ) ->


    encode: ->
        encoded = []
        encoded.push(@emissivity.array()...)
        encoded.push(@specularity)
        encoded.push(@specularReflectivity.array()...)
        encoded.push(@diffuseReflectivity.array()...)
        encoded
