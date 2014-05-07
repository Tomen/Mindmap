part of springy_dart;


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

