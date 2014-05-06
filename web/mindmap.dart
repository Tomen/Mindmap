import 'dart:html' as html;
import "../lib/springy_dart.dart";
import "../lib/springy_renderer.dart";

void main() {
  var canvas = html.querySelector('#stage');
 
  Graph graph = new Graph();
   
  graph.addNodes(['mark', 'higgs', 'other', 'etc']);
  graph.addEdges([
      ['mark', 'higgs'],
      ['mark', 'etc'],
      ['mark', 'other']
  ]);
  
  SpringyRenderer renderer = new SpringyRenderer(canvas);
  renderer.graph = graph;
}