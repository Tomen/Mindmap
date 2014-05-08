part of springy_dart;


class Layout {
  Graph _graph;
  Graph get graph => _graph;
  num _width;
  num _height;
  
  Map<dynamic, Vector> _nodePositions = {}; // keep track of points associated with nodes
  
  Layout(Graph graph, num width, num height){
    _graph = graph;
    _width = width;
    _height = height;
  }

  Vector position(Node node) {
    if (!_nodePositions.containsKey(node.id)) {
      _nodePositions[node.id] = new Vector.random(_width, _height);
    }

    return _nodePositions[node.id];
  }


  // callback should accept two arguments: Node, Point
  eachNode(Function fn(Node node, Vector position)) {
    _graph.nodes.forEach((Node n){
      fn(n, this.position(n));
    });
  }
  
  // callback should accept one argument: Edge
  eachEdge(Function fn(Edge edge)) {
    _graph.edges.forEach((Edge e){
      fn(e);
    });
  }

  // Find the nearest point to a particular position
  nearest(pos) {
    Map min = {"node": null, "point": null, "distance": null};
    _graph.nodes.forEach((Node n){
      var position = this.position(n);
      var distance = (position - pos).magnitude();

      if (!min.containsKey("distance") || distance < min["distance"]) {
        min = {"node": n, "point": position, "distance": distance};
      }
    });

    return min;
  }
  
  // returns [bottomleft, topright]
  getBoundingBox() {
    var bottomleft = new Vector(-2,-2);
    var topright = new Vector(2,2);

    this.eachNode((n, position) {
      if (position.x < bottomleft.x) {
        bottomleft.x = position.x;
      }
      if (position.y < bottomleft.y) {
        bottomleft.y = position.y;
      }
      if (position.x > topright.x) {
        topright.x = position.x;
      }
      if (position.y > topright.y) {
        topright.y = position.y;
      }
    });

    var padding = (topright - bottomleft) * 0.07; // ~5% padding

    return {bottomleft: bottomleft - padding, topright: topright + padding};
  }

}

/* Graph Setter that installs a graph listener
set graph (graph){
  if(_graph != null) {
    _graph.removeGraphListener(this);
  }
  
  _graph = graph;  

  if(_graph != null) {
    renderGraph();
    _graph.addGraphListener(this);
  }
}
*/