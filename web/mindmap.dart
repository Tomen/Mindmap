import 'dart:html' as html;
import "../lib/mindmap.dart";

void main() {
  var canvas = html.querySelector('#stage');
 
  Mindmap mindmap = new Mindmap();
   
  mindmap.addNode(100, 100);
}