part of springy_dart;


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

