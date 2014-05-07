part of springy_dart;


class Vector {
  num x;
  num y;
  
  Vector(x,y);

  Vector.random() {
    this.x = 10.0 * (_random.nextDouble() - 0.5);
    this.y = 10.0 * (_random.nextDouble() - 0.5);
  }

  add(v2) {
    return new Vector(this.x + v2.x, this.y + v2.y);
  }

  subtract(v2) {
    return new Vector(this.x - v2.x, this.y - v2.y);
  }

  multiply(n) {
    return new Vector(this.x * n, this.y * n);
  }

  divide(n) {
    return new Vector((this.x / n) || 0, (this.y / n) || 0); // Avoid divide by zero errors..
  }

  magnitude() {
    return Math.sqrt(this.x*this.x + this.y*this.y);
  }

  normal() {
    return new Vector(-this.y, this.x);
  }

  normalise() {
    return this.divide(this.magnitude());
  }

}

