part of springy_dart;

class ForceDirector {
  
  Layout _layout;
  
  num stiffness; // spring stiffness constant
  num repulsion; // repulsion constant
  num damping; // velocity damping factor  
  Map edgeSprings = {}; // keep track of springs associated with edges

  Map _nodePoints = {}; // keep track of points associated with nodes

  ForceDirector(Layout layout, num stiffness, num repulsion, num damping){
    _layout = layout;
    this.stiffness = stiffness;
    this.repulsion = repulsion;
    this.damping = damping;
  }

  step(num time) {
   this.applyCoulombsLaw();
   this.applyHookesLaw();
   this.attractToCentre();
   this.updateVelocity(time/100);
   this.updatePosition(time/100);

   // stop simulation when energy of the system goes below a threshold
   if (this.totalEnergy() < 0.01) {
     print("could stop now, totalEnerchy reached 0");
   }
  }

  Point point(Node node) {
    if (!_nodePoints.containsKey(node.id)) {
      var mass = (node.data["mass"] != null) ? node.data["mass"] : 1.0;
      Vector position = _layout.position(node);
      Point point = new Point(position, mass);
      _nodePoints[node.id] = point;
      print("Pointing node " + node.id.toString() + " with position hash " + position.hashCode.toString());
    }

    return _nodePoints[node.id];
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

      if (existingSpring != null) {
        return new Spring(existingSpring.point2, existingSpring.point1, 0.0, 0.0);
      }

      this.edgeSprings[edge.id] = new Spring(
        point(edge.source), point(edge.target), length, this.stiffness
      );
    }

    return this.edgeSprings[edge.id];
  }
  
  // callback should accept two arguments: Node, Point
  eachNode(Function fn(Node node, Point point)) {
    _layout.graph.nodes.forEach((Node n){
      fn(n, this.point(n));
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
   this.eachNode((Node n1, Point point1) {
     this.eachNode((Node n2, Point point2) {
       if (point1 != point2)
       {
         var d = point1.p - point2.p;
         var distance = d.magnitude() + 0.1; // avoid massive forces at small distances (and divide by zero)
         var direction = d.normalise();
  
         // apply force to each end point
         point1.applyForce((direction * this.repulsion) / (distance * distance * 0.5));
         point2.applyForce((direction * this.repulsion) / (distance * distance * -0.5));
       }
     });
   });
  }
  
  applyHookesLaw() {
   this.eachSpring((spring){
     var d = spring.point2.p - spring.point1.p; // the direction of the spring
     var displacement = spring.length - d.magnitude();
     var direction = d.normalise();
  
     // apply force to each end point
     spring.point1.applyForce(direction * (spring.k * displacement * -0.5));
     spring.point2.applyForce(direction * (spring.k * displacement * 0.5));
   });
  }
  
  attractToCentre() {
   this.eachNode((node, point) {
     var direction = point.p * (-1.0);
     point.applyForce(direction * (this.repulsion / 50.0));
   });
  }
  
  updateVelocity(timestep) {
   this.eachNode((node, point) {
     // Is this, along with updatePosition below, the only places that your
     // integration code exist?
     point.v = point.v + (point.a * timestep) * this.damping;
     point.a = new Vector(0,0);
   });
  }
  
  updatePosition(timestep) {
    this.eachNode((node, point) {
     // Same question as above; along with updateVelocity, is this all of
     // your integration code?
     Vector p = point.p + point.v * timestep; 
     point.p.x = p.x;
     point.p.y = p.y;     
     print("Physicing node " + node.id.toString() + " with position hash " + point.p.hashCode.toString());
    });
  }
  
  // Calculate the total kinetic energy of the system
  totalEnergy() {
   var energy = 0.0;
   this.eachNode((node, point) {
     var speed = point.v.magnitude();
     energy += 0.5 * point.m * speed * speed;
   });
  
   return energy;
  }
    
}