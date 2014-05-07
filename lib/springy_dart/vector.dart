part of springy_dart;


class Vector {
  num x;
  num y;
  
  Vector(this.x, this.y);

  Vector.random(num xMax, num yMax) {
    this.x = xMax * (_random.nextDouble());
    this.y = yMax * (_random.nextDouble());
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
    if(n == 0){
      return new Vector(0, 0);
    }
    return new Vector(this.x / n, this.y / n); // Avoid divide by zero errors..
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

