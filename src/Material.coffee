###
    The diffuse reflectivity, specular reflectivity, and emission color
    attributes are determined by a multiplier and optionally a texture.
    If a texture is provided, then the color is determined by
    (multiplier * texture), otherwise it is determined by the multiplier alone.
###
class Material
    # Value that is used to indicate that a material component has no
    # associated texture
    NO_IMAGE_ADDRESS = -1


    constructor: () ->
        @specularity        = 0.5
        @diffuseMultiplier  = new Vec3(1.0)
        @specularMultiplier = new Vec3(1.0)
        @emissionMultiplier = new Vec3(0.0)
        @diffuseImage  = null
        @specularImage = null
        @emissionImage = null


    # TODO: wait for these promises to resolve before doing anything with the images
    # Right now, chromium requires the page to be at least once reloaded before it
    # will work
    setDiffuseImage: (diffuseImageSrc) ->
        @diffuseImage = new Image()
        loadedPromise = new Promise((resolve) => @diffuseImage.onload = resolve)
        @diffuseImage.src = diffuseImageSrc
        loadedPromise


    setSpecularImage: (specularImageSrc) ->
        @specularImage = new Image()
        loadedPromise = new Promise((resolve) => @specularImage.onload = resolve)
        @specularImage.src = specularImageSrc
        loadedPromise


    setEmissionImage: (emissionImageSrc) ->
        @emissionImage = new Image()
        loadedPromise = new Promise((resolve) => @emissionImage.onload = resolve)
        @emissionImage.src = emissionImageSrc
        loadedPromise



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
        `material.diffuseMultiplier = new Vec3(...obj.diffuseMultiplier)`
        `material.specularMultiplier = new Vec3(...obj.specularMultiplier)`
        `material.emissionMultiplier = new Vec3(...obj.emissionMultiplier)`

        if obj.diffuseImage?  then material.setDiffuseImage(obj.diffuseImage)
        if obj.specularImage? then material.setSpecularImage(obj.specularImage)
        if obj.emissionImage? then material.setEmissionImage(obj.emissionImage)

        material


    encode: (existingImagesBaseIndex) ->
        images = []

        pushImageIfitExists = (image) ->
            if image is null
                return [NO_IMAGE_ADDRESS, 0, 0]

            imageIndex = existingImagesBaseIndex + images.length
            images.push(image)

            [imageIndex, image.width, image.height]

        encoded = []
        encoded.push(@specularity)
        encoded.push(@diffuseMultiplier.array()...)
        encoded.push(@specularMultiplier.array()...)
        encoded.push(@emissionMultiplier.array()...)
        encoded.push(pushImageIfitExists(@diffuseImage)...)
        encoded.push(pushImageIfitExists(@specularImage)...)
        encoded.push(pushImageIfitExists(@emissionImage)...)

        [encoded, images]
