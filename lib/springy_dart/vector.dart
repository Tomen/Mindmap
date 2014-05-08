part of springy_dart;


class Vector {
  num x;
  num y;
  
  Vector(this.x, this.y);

  Vector.random(num xMax, num yMax) {
    this.x = xMax * (_random.nextDouble());
    this.y = yMax * (_random.nextDouble());
  }

  operator +(Vector v2) {
    return new Vector(this.x + v2.x, this.y + v2.y);
  }
  
  /*
  operator +=(Vector v2)
  {
    this.x += v2.x;
    this.y += v2.y;
  }
  */

  Vector operator -(Vector v2) {
    return new Vector(this.x - v2.x, this.y - v2.y);
  }

  Vector operator *(num n) {
    return new Vector(this.x * n, this.y * n);
  }

  operator /(num n) {
    if(n == 0){
      return new Vector(0, 0);
    }
    return new Vector(this.x / n, this.y / n); // Avoid divide by zero errors..
  }

  num magnitude() {
    return Math.sqrt(this.x*this.x + this.y*this.y);
  }

  Vector normal() {
    return new Vector(-this.y, this.x);
  }

  Vector normalise() {
    return this / this.magnitude();
  }

}

