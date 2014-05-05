part of mindmap;

class ForceDirectedGraphPhysicsSimulator {

  num stiffness;
  num repulsion;
  num damping;
  List<Node> nodes;
  List<Edge> edges;
  
  ForceDirectedGraphPhysicsSimulator(stiffness, repulsion, damping, nodes, relationships);

  _applyCoulombsLaw() {
    for(Node node1 in nodes){
      for(Node node2 in nodes) {
        if (node1 != node2)
        {
          var d = node1.p.subtract(node2.p);
          var distance = d.magnitude() + 0.1; // avoid massive forces at small distances (and divide by zero)
          var direction = d.normalise();

          // apply force to each end point
          node1.applyForce(direction.multiply(this.repulsion).divide(distance * distance * 0.5));
          node2.applyForce(direction.multiply(this.repulsion).divide(distance * distance * -0.5));
        }      
      }
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