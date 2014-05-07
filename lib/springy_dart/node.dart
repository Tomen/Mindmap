part of springy_dart;


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
