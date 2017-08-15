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
        @setDiffuseImage(null)
        @setSpecularImage(null)
        @setEmissionImage(null)


    setSpecularity:        (@specularity)        ->
    setDiffuseMultiplier:  (@diffuseMultiplier)  ->
    setSpecularMultiplier: (@specularMultiplier) ->
    setEmissionMultiplier: (@emissionMultiplier) ->
    setDiffuseImage:       (@diffuseImage)       ->
    setSpecularImage:      (@specularImage)      ->
    setEmissionImage:      (@emissionImage)      ->


    toJSONEncodableObj: ->
        obj =
            specularity:         @specularity
            diffuseMultiplier:   @diffuseMultiplier.array()
            specularMultiplier:  @specularMultiplier.array()
            emissionMultiplier:  @emissionMultiplier.array()

        if @diffuseImage?  then obj.diffuseImage  = @diffuseImage
        if @specularImage? then obj.specularImage = @specularImage
        if @emissionImage? then obj.emissionImage = @emissionImage

        obj


    @fromJSONEncodableObj: (obj) ->
        unless obj.specularity? and
               obj.diffuseMultiplier? and
               obj.specularMultiplier? and
               obj.emissionMultiplier?
            throw "Invalid JSON!"

        # TODO: validate data fully

        material = new Material()
        material.setSpecularity(obj.specularity)
        material.setDiffuseMultiplier(new Vec3(obj.diffuseMultiplier...))
        material.setSpecularMultiplier(new Vec3(obj.specularMultiplier...))
        material.setEmissionMultiplier(new Vec3(obj.emissionMultiplier...))

        if obj.diffuseImage?  then material.setDiffuseImage(obj.diffuseImage)
        if obj.specularImage? then material.setSpecularImage(obj.specularImage)
        if obj.emissionImage? then material.setEmissionImage(obj.emissionImage)

        material


    encode: (images) ->
        pushImageIfExists = (image) ->
            unless image then return [-1, 0, 0]
            index = images.length
            images.push(image)
            # TODO: find proper resolution
            [index, 200, 200]#image.width, image.height]

        encoded = []
        encoded.push(@specularity)
        encoded.push(@diffuseMultiplier.array()...)
        encoded.push(@specularMultiplier.array()...)
        encoded.push(@emissionMultiplier.array()...)
        encoded.push(pushImageIfExists(@diffuseImage)...)
        encoded.push(pushImageIfExists(@specularImage)...)
        encoded.push(pushImageIfExists(@emissionImage)...)
        encoded
