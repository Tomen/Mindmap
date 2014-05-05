import "core/mindmap_core.dart";
import "graphics/mindmap_renderer.dart";
export "graphics/mindmap_renderer.dart";

class Mindmap implements MindmapController {
  Graph _graph;
  Graph get graph => _graph;
  
  MindmapRenderer renderer;
  
  Mindmap();
  
  Node addNode(num x, num y){
    Node node = new Node(x, y);
    return node;
  }
  
  Edge addRelationship(Node meme1, Node meme2){
    Edge relationship = new Edge(meme1, meme2);
    //meme1.edges.add(relationship);
    //meme2.edges.add(relationship);
    return relationship;
  }

  addChildNode(Node parent){
    Node childMeme = _mindmap.addNode(this.x, this.y + boxHeight + 5);
    _mindmap.addRelationship(this, childMeme);
  }

}