part of springy_dart;

class Spring {
  
  Point point1;
  Point point2;
  num length; // spring length at rest
  num k; // spring constant (See Hooke's law) .. how stiff the spring is
  
  Spring(point1, point2, length, k) {
    this.point1 = point1;
    this.point2 = point2;
    this.length = length; 
    this.k = k; 
  }  
}