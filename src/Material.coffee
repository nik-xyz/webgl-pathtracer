###
    The diffuse reflectivity, specular reflectivity, and emission color
    attributes are determined by a multiplier and optionally a texture.
    If a texture is provided, then the color is determined by
    (multiplier * texture), otherwise it is determined by the multiplier alone.
###
class Material
    constructor: () ->
        @specularity        = 0.5
        @diffuseMultiplier  = new Vec3(1.0)
        @specularMultiplier = new Vec3(1.0)
        @emissionMultiplier = new Vec3(0.0)
        @diffuseImage  = null
        @specularImage = null
        @emissionImage = null


    # TODO: make these block until the image has been loaded
    setDiffuseImage: (diffuseImageSrc) ->
        @diffuseImage  = new Image()
        @diffuseImage.src = diffuseImageSrc


    setSpecularImage: (specularImageSrc) ->
        @specularImage = new Image()
        @specularImage.src = specularImageSrc


    setEmissionImage: (emissionImageSrc) ->
        @emissionImage = new Image()
        @emissionImage.src = emissionImageSrc



    toJSONEncodableObj: ->
        obj =
            specularity:         @specularity
            diffuseMultiplier:   @diffuseMultiplier.array()
            specularMultiplier:  @specularMultiplier.array()
            emissionMultiplier:  @emissionMultiplier.array()

        if @diffuseImage?  then obj.diffuseImage  = @diffuseImage.src
        if @specularImage? then obj.specularImage = @specularImage.src
        if @emissionImage? then obj.emissionImage = @emissionImage.src

        obj


    @fromJSONEncodableObj: (obj) ->
        unless obj.specularity? and
               obj.diffuseMultiplier? and
               obj.specularMultiplier? and
               obj.emissionMultiplier?
            throw "Invalid JSON!"

        # TODO: validate data fully

        material = new Material()
        material.specularity = obj.specularity
        material.diffuseMultiplier = new Vec3(obj.diffuseMultiplier...)
        material.specularMultiplier = new Vec3(obj.specularMultiplier...)
        material.emissionMultiplier = new Vec3(obj.emissionMultiplier...)

        if obj.diffuseImage?  then material.setDiffuseImage(obj.diffuseImage)
        if obj.specularImage? then material.setSpecularImage(obj.specularImage)
        if obj.emissionImage? then material.setEmissionImage(obj.emissionImage)

        material


    encode: (images) ->
        pushImageIfExists = (image) ->
            unless image then return [-1, 0, 0]
            index = images.length
            images.push(image)
            [index, image.width, image.height]

        encoded = []
        encoded.push(@specularity)
        encoded.push(@diffuseMultiplier.array()...)
        encoded.push(@specularMultiplier.array()...)
        encoded.push(@emissionMultiplier.array()...)
        encoded.push(pushImageIfExists(@diffuseImage)...)
        encoded.push(pushImageIfExists(@specularImage)...)
        encoded.push(pushImageIfExists(@emissionImage)...)
        encoded
