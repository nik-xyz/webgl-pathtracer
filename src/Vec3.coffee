class Vec3
    constructor: (@x = 0, @y = 0, @z = 0) ->

    map:     (fn)        -> new Vec3(fn(@x), fn(@y), fn(@z))
    combine: (other, fn) -> new Vec3(fn(@x, other.x), fn(@y, other.y), fn(@z, other.z))
    add:     (other)     -> @combine(other, (a, b) -> a + b)
    sub:     (other)     -> @combine(other, (a, b) -> a - b)
    mul:     (other)     -> @combine(other, (a, b) -> a * b)
    div:     (other)     -> @combine(other, (a, b) -> a / b)
    min:     (other)     -> @combine(other, (a, b) -> Math.min(a, b))
    max:     (other)     -> @combine(other, (a, b) -> Math.max(a, b))
    dot:     (other)     -> @x * other.x + @y * other.y + @z * other.z
    scale:   (amt)       -> new Vec3(@x * amt, @y * amt, @z * amt)
    dist:    (other)     -> @sub(other).length()
    length:              -> Math.sqrt(@dot(@))
    array:               -> [@x, @y, @z]
