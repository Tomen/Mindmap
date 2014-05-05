part of mindmap_core;

<<<<<<< HEAD
class Edge {
=======
abstract class Edge {
>>>>>>> 27e7dbb2e5a6e3a78e370674c326a18b1ad60a2a
  Node node1;
  Node node2;
    
  Edge(Node node1, Node node2){
    this.node1 = node1;
    this.node2 = node2;
    //TODO: inform renderer
  }
}