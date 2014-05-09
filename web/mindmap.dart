import 'dart:html' as html;
import "../lib/springy_dart/springy_dart.dart";
import "springy_renderer.dart";

void main() {
  var canvas = html.querySelector('#stage');
 
  Graph graph = new Graph();
   
  graph.addNodes(['mark', 'higgs', 'other', 'etc']);
  graph.addEdges([
      ['mark', 'higgs'],
      ['mark', 'etc'],
      ['etc', 'higgs']
  ]);
  
  SpringyRenderer renderer = new SpringyRenderer(canvas, graph);
}