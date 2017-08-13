class Vec
    add:   (other) -> @combine(other, (a, b) -> a + b)
    sub:   (other) -> @combine(other, (a, b) -> a - b)
    mul:   (other) -> @combine(other, (a, b) -> a * b)
    div:   (other) -> @combine(other, (a, b) -> a / b)
    min:   (other) -> @combine(other, Math.min)
    max:   (other) -> @combine(other, Math.max)
    less:  (other) -> @combine(other, (a, b) -> (a < b))
    dot:   (other) -> @mul(other).reduce((a, b) -> a + b)
    scale: (amt)   -> @map((a) -> a * amt)
    dist:  (other) -> @sub(other).length()
    length:        -> Math.sqrt(@dot(@))


class Vec2 extends Vec
    constructor: (@x = 0, @y = @x) ->

    map:     (fn)        -> new Vec2(fn(@x), fn(@y))
    combine: (other, fn) -> new Vec2(fn(@x, other.x), fn(@y, other.y))
    reduce:  (fn)        -> fn(@x, @y)
    array:               -> [@x, @y]


class Vec3 extends Vec
    constructor: (@x = 0, @y = @x, @z = @x) ->

    map:     (fn)        -> new Vec3(fn(@x), fn(@y), fn(@z))
    combine: (other, fn) -> new Vec3(fn(@x, other.x), fn(@y, other.y), fn(@z, other.z))
    reduce:  (fn)        -> fn(fn(@x, @y), @z)
    array:               -> [@x, @y, @z]
