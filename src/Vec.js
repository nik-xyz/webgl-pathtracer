class Vec {
    add(other)  { return this.combine(other, (a, b) => a + b); }
    sub(other)  { return this.combine(other, (a, b) => a - b); }
    mul(other)  { return this.combine(other, (a, b) => a * b); }
    div(other)  { return this.combine(other, (a, b) => a / b); }
    less(other) { return this.combine(other, (a, b) => a < b); }
    min(other)  { return this.combine(other, Math.min);        }
    max(other)  { return this.combine(other, Math.max);        }

    dot(other)  { return this.mul(other).reduce((a, b) => a + b); }
    scale(amt)  { return this.map(val => val * amt); }
    dist(other) { return this.sub(other).length(); }
    length()    { return Math.sqrt(this.dot(this)); }

    reduce(fn)  { return this.array().reduce(fn); }

    checkNumeric() {
        if(this.array().every(Number.isFinite)) {
            return this;
        }
        throw new Error("vector contains element that is not a number");
    }
}

class Vec2 extends Vec {
    constructor(x = 0, y = x) {
        super();
        [this.x, this.y] = [x, y];
    }

    static fromJSONEncodableObj(obj) {
        if((0 in obj) && (1 in obj)) {
            return new Vec2(obj[0], obj[1]);
        }
        throw new Error("invalid JSON");
    }

    map(fn) {
        return new Vec2(fn(this.x), fn(this.y));
    }

    combine(other, fn) {
        return new Vec2(fn(this.x, other.x), fn(this.y, other.y));
    }

    array() {
        return [this.x, this.y];
    }
}

class Vec3 extends Vec {
    constructor(x = 0, y = x, z = y) {
        super();
        [this.x, this.y, this.z] = [x, y, z];
    }

    static fromJSONEncodableObj(obj) {
        if((0 in obj) && (1 in obj) && (2 in obj)) {
            return new Vec3(obj[0], obj[1], obj[2]);
        }
        throw new Error("invalid JSON");
    }

    map(fn) {
        return new Vec3(fn(this.x), fn(this.y), fn(this.z));
    }

    combine(other, fn) {
        return new Vec3(fn(this.x, other.x), fn(this.y, other.y), fn(this.z, other.z));
    }

    array() {
        return [this.x, this.y, this.z];
    }
}
