part of springy_dart;


class Point {

  Vector p; // position
  num m; // mass
  Vector v; // velocity
  Vector a; // acceleration

  Point(position, mass) {
    this.p = position;
    this.m = mass;
    this.v = new Vector(0, 0);
    this.a = new Vector(0, 0);
  }

  applyForce(Vector force) {
    this.a = a + (force / this.m);
  }
}

