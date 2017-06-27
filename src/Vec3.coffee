class Vec3
    constructor: (@x, @y, @z) ->

    add: (other)  -> new Vec3(@x + other.x, @y + other.y, @z + other.z)
    sub: (other)  -> new Vec3(@x - other.x, @y - other.y, @z - other.z)
    scale: (amt)  -> new Vec3(@x * amt, @y * amt, @z * amt)
    dot: (other)  -> @x * other.x + @y * other.y + @z * other.z
    length:       -> Math.sqrt(@.dot(@))
    dist: (other) -> @.sub(other).length()
    array:        -> [@x, @y, @z]
