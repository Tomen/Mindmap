part of mindmap;

class ForceDirectedGraphPhysicsSimulator {

  num stiffness;
  num repulsion;
  num damping;
  List<Meme> nodes;
  List<Relationship> relationships;
  
  ForceDirectedGraphPhysicsSimulator(stiffness, repulsion, damping, nodes, relationships);

  _applyCoulombsLaw() {
    //foreach node
      //foreach node
    var point1;
    var point2;
     if (point1 != point2)
     {
       var d = point1.p.subtract(point2.p);
       var distance = d.magnitude() + 0.1; // avoid massive forces at small distances (and divide by zero)
       var direction = d.normalise();

       // apply force to each end point
       point1.applyForce(direction.multiply(this.repulsion).divide(distance * distance * 0.5));
       point2.applyForce(direction.multiply(this.repulsion).divide(distance * distance * -0.5));
     }
  }

 _applyHookesLaw() {
   //For each relationship
   var d = spring.point2.p.subtract(spring.point1.p); // the direction of the spring
   var displacement = spring.length - d.magnitude();
   var direction = d.normalise();

   // apply force to each end point
   spring.point1.applyForce(direction.multiply(spring.k * displacement * -0.5));
   spring.point2.applyForce(direction.multiply(spring.k * displacement * 0.5));
}

_attractToCentre() {
//for each node
  var direction = point.p.multiply(-1.0);
   point.applyForce(direction.multiply(this.repulsion / 50.0));
}


_updateVelocity(timestep) {
//for each node
  // Is this, along with updatePosition below, the only places that your
   // integration code exist?
   point.v = point.v.add(point.a.multiply(timestep)).multiply(this.damping);
   point.a = new Vector(0,0);
 
}

_updatePosition(timestep) {
//for each node
  // Same question as above; along with updateVelocity, is this all of
   // your integration code?
   point.p = point.p.add(point.v.multiply(timestep));
 
}

}