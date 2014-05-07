part of springy_dart;


class Layout {
  Graph _graph;
  Graph get graph => _graph;
  
  Map _nodePoints = {}; // keep track of points associated with nodes
  
  Layout(Graph graph);

  Point point(node) {
    if (!_nodePoints.containsKey(node.id)) {
      var mass = (node.data.mass != null) ? node.data.mass : 1.0;
      _nodePoints[node.id] = new Point(new Vector.random(), mass);
    }

    return _nodePoints[node.id];
  }


  // callback should accept two arguments: Node, Point
  eachNode(Function fn(Node node, Point point)) {
    _graph.nodes.forEach((Node n){
      fn(n, this.point(n));
    });
  }

  // Find the nearest point to a particular position
  nearest(pos) {
    Map min = {"node": null, "point": null, "distance": null};
    var t = this;
    _graph.nodes.forEach((Node n){
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