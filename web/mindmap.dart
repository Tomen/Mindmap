import 'dart:html' as html;
import "../lib/springy_dart/springy_dart.dart";
import "springy_renderer.dart";

void main() {
  var canvas = html.querySelector('#stage');
 
  Graph graph = new Graph();
  
  //var names = ['Dennis', 'Michael', 'Jessica', 'Timothy', 'Barbara', 'Franklin', 'Monty', 'James', 'Bianca'];
  var names = ['Dennis', 'Michael', 'Jessica', 'Timothy'];
  List<Node> nodes = graph.addNodes(names);
  
  for(int i = 0; i < nodes.length - 1; i++) {
    Node node = nodes[i];
    Node nextNode = nodes[i+1];
    graph.newEdge(node, nextNode, {});
  }
  
  graph.newEdge(nodes.first, nodes.last, {});
  
  SpringyRenderer renderer = new SpringyRenderer(canvas, graph);
}