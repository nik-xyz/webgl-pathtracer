###
    The diffuse reflectivity, specular reflectivity, and emission color
    attributes are determined by a multiplier and optionally a texture.
    If a texture is provided, then the color is determined by
    (multiplier * texture), otherwise it is determined by the multiplier alone.
###
class Material
    constructor: () ->
        @setSpecularity(0.5)
        @setDiffuseMultiplier(new Vec3(1.0))
        @setSpecularMultiplier(new Vec3(1.0))
        @setEmissionMultiplier(new Vec3(0.0))
        @setDiffuseTexture(null)
        @setSpecularTexture(null)
        @setEmissionTexture(null)


    setSpecularity:        (@specularity) ->
    setDiffuseMultiplier:  (@diffuseMultiplier)  ->
    setSpecularMultiplier: (@specularMultiplier) ->
    setEmissionMultiplier: (@emissionMultiplier) ->
    setDiffuseTexture:     (@diffuseImage)  ->
    setSpecularTexture:    (@specularImage) ->
    setEmissionTexture:    (@emissionImage) ->


    encode: (images) ->
        pushImageIfExists = (image) ->
            unless image then return -1
            index = images.length
            images.push(image)
            index

        encoded = []
        encoded.push(@specularity)
        encoded.push(@diffuseMultiplier.array()...)
        encoded.push(@specularMultiplier.array()...)
        encoded.push(@emissionMultiplier.array()...)
        encoded.push(pushImageIfExists(@diffuseImage))
        encoded.push(pushImageIfExists(@specularImage))
        encoded.push(pushImageIfExists(@emissionImage))
        encoded
