part of springy_dart;

class ForceDirector {
  
  Layout _layout;
  
  num stiffness; // spring stiffness constant
  num repulsion; // repulsion constant
  num damping; // velocity damping factor  
  Map edgeSprings; // keep track of springs associated with edges

  ForceDirector(Layout _layout, num stiffness, num repulsion, num damping);

  step() {
   this.applyCoulombsLaw();
   this.applyHookesLaw();
   this.attractToCentre();
   this.updateVelocity(0.03);
   this.updatePosition(0.03);

   // stop simulation when energy of the system goes below a threshold
   if (this.totalEnergy() < 0.01) {
     print("could stop now, totalEnerchy reached 0");
   }
  }

  Spring spring(edge) {
    if (!this.edgeSprings.containsKey(edge.id)) {
      var length = (edge.data.length != null) ? edge.data.length : 1.0;

      var existingSpring = null;

      var from = _layout.graph.getEdges(edge.source, edge.target);
      from.forEach((Edge e) {
        if (existingSpring == false && this.edgeSprings.containsKey(e.id)) {
          existingSpring = this.edgeSprings[e.id];
        }
      });

      if (existingSpring != null) {
        return new Spring(existingSpring.point1, existingSpring.point2, 0.0, 0.0);
      }

      var to = _layout.graph.getEdges(edge.target, edge.source);
      from.forEach((Edge e){
        if (existingSpring == false && this.edgeSprings.containsKey(e.id)) {
          existingSpring = this.edgeSprings[e.id];
        }
      });

      if (existingSpring != false) {
        return new Spring(existingSpring.point2, existingSpring.point1, 0.0, 0.0);
      }

      this.edgeSprings[edge.id] = new Spring(
        _layout.point(edge.source), _layout.point(edge.target), length, this.stiffness
      );
    }

    return this.edgeSprings[edge.id];
  }

  // callback should accept two arguments: Edge, Spring
  eachEdge(Function fn(Edge edge, Spring spring)) {
    _layout.graph.edges.forEach((Edge e){
      fn(e, this.spring(e));
    });
  }

  // callback should accept one argument: Spring
  eachSpring(Function fn(Spring spring)) {
    _layout.graph.edges.forEach((Edge e){
      fn(this.spring(e));
    });
  }

  
  // Physics stuff
  applyCoulombsLaw() {
   _layout.eachNode((n1, point1) {
     _layout.eachNode((n2, point2) {
       if (point1 != point2)
       {
         var d = point1.p.subtract(point2.p);
         var distance = d.magnitude() + 0.1; // avoid massive forces at small distances (and divide by zero)
         var direction = d.normalise();
  
         // apply force to each end point
         point1.applyForce(direction.multiply(this.repulsion).divide(distance * distance * 0.5));
         point2.applyForce(direction.multiply(this.repulsion).divide(distance * distance * -0.5));
       }
     });
   });
  }
  
  applyHookesLaw() {
   this.eachSpring((spring){
     var d = spring.point2.p.subtract(spring.point1.p); // the direction of the spring
     var displacement = spring.length - d.magnitude();
     var direction = d.normalise();
  
     // apply force to each end point
     spring.point1.applyForce(direction.multiply(spring.k * displacement * -0.5));
     spring.point2.applyForce(direction.multiply(spring.k * displacement * 0.5));
   });
  }
  
  attractToCentre() {
   _layout.eachNode((node, point) {
     var direction = point.p.multiply(-1.0);
     point.applyForce(direction.multiply(this.repulsion / 50.0));
   });
  }
  
  updateVelocity(timestep) {
   _layout.eachNode((node, point) {
     // Is this, along with updatePosition below, the only places that your
     // integration code exist?
     point.v = point.v.add(point.a.multiply(timestep)).multiply(this.damping);
     point.a = new Vector(0,0);
   });
  }
  
  updatePosition(timestep) {
   _layout.eachNode((node, point) {
     // Same question as above; along with updateVelocity, is this all of
     // your integration code?
     point.p = point.p.add(point.v.multiply(timestep));
   });
  }
  
  // Calculate the total kinetic energy of the system
  totalEnergy() {
   var energy = 0.0;
   _layout.eachNode((node, point) {
     var speed = point.v.magnitude();
     energy += 0.5 * point.m * speed * speed;
   });
  
   return energy;
  }
    
}