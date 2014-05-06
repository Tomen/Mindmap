/**
 * SpringyDart v1.0.0
 * 
 * Copyright (c) 2014 Tommi Enenkel
 * 
 * based on: Springy v2.3.0
 *
 * Copyright (c) 2010-2013 Dennis Hotson
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

library springydart;

import "dart:convert";
import "dart:math" as Math;

Math.Random _random = new Math.Random();

class Graph {
  Map nodeSet = {};
  List nodes = [];
  List edges = [];
  Map<Object, Map<Object, List<Edge>>> adjacency = {};
  
  num nextNodeId = 0;
  num nextEdgeId = 0;
  List eventListeners = [];
  
  Node addNode(Node node) {
    if (!this.nodeSet.containsKey(node.id)) {
      this.nodes.add(node);
    }

    this.nodeSet[node.id] = node;

    this.notify();
    return node;
  }
  
  addNodes(List<String> arguments) {
     // accepts variable number of arguments, where each argument
     // is a string that becomes both node identifier and label
     for (var i = 0; i < arguments.length; i++) {
       var name = arguments[i];
       var node = new Node(name, {"label":name});
       this.addNode(node);
     }
   }
   

  Edge addEdge(Edge edge) {
    var exists = false;
   
    this.edges.forEach((Edge e) {
      if (edge.id == e.id) {
        exists = true; 
      }
    });

    if (!exists) {
      this.edges.add(edge);
    }

    if (!this.adjacency.containsKey(edge.source.id)) {
      this.adjacency[edge.source.id] = {};
    }
   
    if (!this.adjacency[edge.source.id].containsKey(edge.target.id)) {
      this.adjacency[edge.source.id][edge.target.id] = [];
    }

    exists = false;
    this.adjacency[edge.source.id][edge.target.id].forEach((Edge e) {
      if (edge.id == e.id) { exists = true; }
    });

    if (!exists) {
      this.adjacency[edge.source.id][edge.target.id].add(edge);
    }

    this.notify();
    return edge;
  }

  addEdges(List<List> arguments) {
    // accepts variable number of arguments, where each argument
    // is a triple [nodeid1, nodeid2, attributes]
    for (var i = 0; i < arguments.length; i++) {
      var e = arguments[i];
      var node1 = this.nodeSet[e[0]];
      if (node1 == null) {
        throw "invalid node name: " + e[0];
      }
      var node2 = this.nodeSet[e[1]];
      if (node2 == null) {
        throw "invalid node name: " + e[1];
      }
      var attr = e.length >= 3 ? e[2] : null;

      this.newEdge(node1, node2, attr);
    }
  }

  Node newNode(data) {
    var node = new Node(this.nextNodeId++, data);
    this.addNode(node);
    return node;
  }

  Edge newEdge(source, target, data) {
    var edge = new Edge(this.nextEdgeId++, source, target, data);
    this.addEdge(edge);
    return edge;
  }
 
 // add nodes and edges from JSON object
  loadJSON(json) {
 /**
 Springy's simple JSON format for graphs.

 historically, Springy uses separate lists
 of nodes and edges:

   {
     "nodes": [
       "center",
       "left",
       "right",
       "up",
       "satellite"
     ],
     "edges": [
       ["center", "left"],
       ["center", "right"],
       ["center", "up"]
     ]
   }

 **/
  // parse if a string is passed (EC5+ browsers)
  if (json is String) {
    json = JSON.decode( json );
  }
   
  if(json is Map && (json.containsKey("nodes") || json.containsKey("edges"))){
    this.addNodes(json['nodes']);
    this.addEdges(json['edges']);
  }
}


  // find the edges from node1 to node2
  List<Edge> getEdges(Node node1, Node node2) {
  if (this.adjacency.containsKey(node1.id)
    && this.adjacency[node1.id].containsKey(node2.id)) {
    return this.adjacency[node1.id][node2.id];
  }

  return <Edge>[];
}

// remove a node and it's associated edges from the graph
  removeNode(node) {
    if (this.nodeSet.containsKey(node.id)) {
      this.nodeSet.remove(node.id);
    }

    for (var i = this.nodes.length - 1; i >= 0; i--) {
      if (this.nodes[i].id == node.id) {
        this.nodes.removeAt(i);
      }
    }

    this.detachNode(node);
  }

 // removes edges associated with a given node
  detachNode(node) {
    var tmpEdges = new List.from(this.edges);
    tmpEdges.forEach((Edge e) {
      if (e.source.id == node.id || e.target.id == node.id) {
        this.removeEdge(e);
      }
    });

    this.notify();
 }

  // remove a node and it's associated edges from the graph
  removeEdge(Edge edge) {
    for (var i = this.edges.length - 1; i >= 0; i--) {
      if (this.edges[i].id == edge.id) {
        this.edges.removeAt(i);
      }
    }

    for (var x in this.adjacency) {
      for (var y in this.adjacency[x]) {
        var edges = this.adjacency[x][y];

        for (var j=edges.length - 1; j>=0; j--) {
          if (this.adjacency[x][y][j].id == edge.id) {
            this.adjacency[x][y].removeAt(j);
          }
        }

        // Clean up empty edge arrays
        if (this.adjacency[x][y].length == 0) {
          this.adjacency[x].remove(y);
        }
      }

      // Clean up empty objects
      if (this.adjacency[x].isEmpty) {
        this.adjacency.remove(x);
      }
    }

    this.notify();
  }

  /* Merge a list of nodes and edges into the current graph. eg.
  var o = {
    nodes: [
      {id: 123, data: {type: 'user', userid: 123, displayname: 'aaa'}},
      {id: 234, data: {type: 'user', userid: 234, displayname: 'bbb'}}
    ],
    edges: [
      {from: 0, to: 1, type: 'submitted_design', directed: true, data: {weight: }}
    ]
  }
  */
  merge(Map data) {
    var nodes = [];
    data["nodes"].forEach((Node n) {
      nodes.add(this.addNode(new Node(n.id, n.data)));
    }, this); 

    data["edges"].forEach((Map e) {
      var from = nodes[e["from"]];
      var to = nodes[e["to"]];

      var id = (e["directed"])
        ? (e["type"] + "-" + from.id + "-" + to.id)
        : (from.id < to.id) // normalise id for non-directed edges
          ? e["type"] + "-" + from.id + "-" + to.id
          : e["type"] + "-" + to.id + "-" + from.id;

      var edge = this.addEdge(new Edge(id, from, to, e["data"]));
      edge.data["type"] = e["type"];
    }, this);
  }

  filterNodes(fn) {
    var tmpNodes = new List.from(this.nodes);
    tmpNodes.forEach((Node n) {
      if (!fn(n)) {
        this.removeNode(n);
      }
    });
  }

  filterEdges(fn) {
    var tmpEdges = new List.from(this.edges);
    tmpEdges.forEach((Edge e) {
      if (!fn(e)) {
        this.removeEdge(e);
      }
    });
  }


  addGraphListener(obj) {
    this.eventListeners.add(obj);
  }
  
  removeGraphListener(obj) {
    this.eventListeners.remove(obj);
  }

  notify() {
    this.eventListeners.forEach((obj) {
      obj.graphChanged();
    });
  }

}

class Node {
  var id;
  Map data;
  // Data fields used by layout algorithm in this file:
  // this.data.mass
  // Data used by default renderer in springyui.js
  // this.data.label
  
  Node(id, Map data) {
    this.id = id;
    this.data = data != null ? data : {};
  }
  
}

class Edge {
  num id;
  Node source;
  Node target;
  Map data;
  // Edge data field used by layout alorithm
  // this.data.length
  // this.data.type
  
  Edge(num id, Node source, Node target, Map data) {
     this.id = id;
     this.source = source;
     this.target = target;
     this.data = data != null ? data : {};
   }
}

class ForceDirectedLayout {
  Graph graph; 
  num stiffness; // spring stiffness constant
  num repulsion; // repulsion constant
  num damping; // velocity damping factor
  
  Map nodePoints; // keep track of points associated with nodes
  Map edgeSprings; // keep track of springs associated with edges
  
  ForceDirectedLayout(Graph graph, num stiffness, num repulsion, num damping) {
    this.graph = graph;
    this.stiffness = stiffness; 
    this.repulsion = repulsion;
    this.damping = damping;

    this.nodePoints = {};
    this.edgeSprings = {};
  }

  point(node) {
    if (!this.nodePoints.containsKey(node.id)) {
      var mass = (node.data.mass != null) ? node.data.mass : 1.0;
      this.nodePoints[node.id] = new Point(new Vector.random(), mass);
    }

    return this.nodePoints[node.id];
  }

  spring(edge) {
    if (!this.edgeSprings.containsKey(edge.id)) {
      var length = (edge.data.length != null) ? edge.data.length : 1.0;

      var existingSpring = null;

      var from = this.graph.getEdges(edge.source, edge.target);
      from.forEach((Edge e) {
        if (existingSpring == false && this.edgeSprings.containsKey(e.id)) {
          existingSpring = this.edgeSprings[e.id];
        }
      });

      if (existingSpring != null) {
        return new Spring(existingSpring.point1, existingSpring.point2, 0.0, 0.0);
      }

      var to = this.graph.getEdges(edge.target, edge.source);
      from.forEach((Edge e){
        if (existingSpring == false && this.edgeSprings.containsKey(e.id)) {
          existingSpring = this.edgeSprings[e.id];
        }
      });

      if (existingSpring != false) {
        return new Spring(existingSpring.point2, existingSpring.point1, 0.0, 0.0);
      }

      this.edgeSprings[edge.id] = new Spring(
        this.point(edge.source), this.point(edge.target), length, this.stiffness
      );
    }

    return this.edgeSprings[edge.id];
  }

  // callback should accept two arguments: Node, Point
  eachNode(callback) {
    var t = this;
    this.graph.nodes.forEach((Node n){
      callback.call(t, n, t.point(n));
    });
  }

  // callback should accept two arguments: Edge, Spring
  eachEdge(callback) {
    var t = this;
    this.graph.edges.forEach((Edge e){
      callback.call(t, e, t.spring(e));
    });
  }

  // callback should accept one argument: Spring
  eachSpring(callback) {
    var t = this;
    this.graph.edges.forEach((Edge e){
      callback.call(t, t.spring(e));
    });
  }

  // Physics stuff
  applyCoulombsLaw() {
    this.eachNode((n1, point1) {
      this.eachNode((n2, point2) {
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
    this.eachNode((node, point) {
      var direction = point.p.multiply(-1.0);
      point.applyForce(direction.multiply(this.repulsion / 50.0));
    });
  }

  updateVelocity(timestep) {
    this.eachNode((node, point) {
      // Is this, along with updatePosition below, the only places that your
      // integration code exist?
      point.v = point.v.add(point.a.multiply(timestep)).multiply(this.damping);
      point.a = new Vector(0,0);
    });
  }

  updatePosition(timestep) {
    this.eachNode((node, point) {
      // Same question as above; along with updateVelocity, is this all of
      // your integration code?
      point.p = point.p.add(point.v.multiply(timestep));
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

  // Find the nearest point to a particular position
  nearest(pos) {
    Map min = {"node": null, "point": null, "distance": null};
    var t = this;
    this.graph.nodes.forEach((Node n){
      var point = t.point(n);
      var distance = point.p.subtract(pos).magnitude();

      if (!min.containsKey("distance") || distance < min["distance"]) {
        min = {"node": n, "point": point, "distance": distance};
      }
    });

    return min;
  }
  
  // returns [bottomleft, topright]
  getBoundingBox() {
    var bottomleft = new Vector(-2,-2);
    var topright = new Vector(2,2);

    this.eachNode((n, point) {
      if (point.p.x < bottomleft.x) {
        bottomleft.x = point.p.x;
      }
      if (point.p.y < bottomleft.y) {
        bottomleft.y = point.p.y;
      }
      if (point.p.x > topright.x) {
        topright.x = point.p.x;
      }
      if (point.p.y > topright.y) {
        topright.y = point.p.y;
      }
    });

    var padding = topright.subtract(bottomleft).multiply(0.07); // ~5% padding

    return {bottomleft: bottomleft.subtract(padding), topright: topright.add(padding)};
  }

}

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

  applyForce(force) {
    this.a = this.a.add(force.divide(this.m));
  }
}

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