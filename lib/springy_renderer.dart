library mindmap_renderer;

import 'package:stagexl/stagexl.dart' as stagexl;
import "springy_dart.dart";

stagexl.DisplayObject draggedObject;
num previousX;
num previousY;

class SpringyRenderer {
  stagexl.Stage _stage;
  stagexl.Stage get stage => _stage;
  
  NodeRenderer _focusedMeme;
  
  Graph _graph;
  Graph get graph => _graph;
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
  
  List<NodeRenderer> _nodeRenderers = <NodeRenderer>[];
  List<EdgeRenderer> _edgeRenderers = <EdgeRenderer>[];

  SpringyRenderer(var canvas){
    
    _stage = new stagexl.Stage(canvas);
    _stage.doubleClickEnabled = true;
    var renderLoop = new stagexl.RenderLoop();
    renderLoop.addStage(_stage);

    var background = new stagexl.Shape();
    background.graphics.rect(0, 0, canvas.clientWidth, canvas.clientHeight);
    background.graphics.fillColor(stagexl.Color.LightGray);
    stage.addChild(background);

    stage.onMouseClick.listen((me){
      this.focusOnNode(null); //defocus current memes      
    });
    
    stage.onMouseDoubleClick.listen((me){
      graph.newNode({"label": "New Node"});
    });

    stage.onMouseMove.listen((stagexl.MouseEvent me){
      if(draggedObject != null){
        num deltaX = previousX - me.stageX;
        num deltaY = previousY - me.stageY;
        draggedObject.x -= deltaX;
        draggedObject.y -= deltaY;
        
        if(draggedObject is NodeRenderer){
          NodeRenderer nodeRenderer = draggedObject;
          for(var edge in nodeRenderer){
            edge.render();
          }
        }
      }
      
      //MouseEvent deltaX and deltaY do not work as of now. Working around them
      previousX = me.stageX;
      previousY = me.stageY;
    });
    
    stage.onMouseUp.listen((stagexl.MouseEvent me){
      draggedObject = null;
    });  
  }
  
  renderGraph() {
    for(NodeRenderer nr in _nodeRenderers) {
      _stage.removeChild(nr);
    }
    
    for(EdgeRenderer er in _edgeRenderers) {
      _stage.removeChild(er);
    }
    
    _nodeRenderers.clear();
    _edgeRenderers.clear();
    
    for(Node node in _graph.nodes) {
      NodeRenderer nr = new NodeRenderer(node);
      _stage.addChild(nr);
      _nodeRenderers.add(nr);
    }
        
    for(Edge edge in _graph.edges) {
      EdgeRenderer er = new EdgeRenderer(edge);
      _stage.addChild(er);
      _edgeRenderers.add(er);
    }
  }
  
  focusOnNode(NodeRenderer nodeRenderer)
  {
    if(_stage.focus != null && _stage.focus is NodeRenderer)
    {
      NodeRenderer focus = _stage.focus;
      focus.isFocus = false;  
    }
    
    _stage.focus = nodeRenderer;
    
    if(nodeRenderer != null)
    {
      nodeRenderer.isFocus = true;
    }
  } 

  
}

class NodeRenderer extends stagexl.Sprite
{    
  Node _node;  

  //MindmapRenderer _mindmapRenderer;
  bool _isFocus;
  stagexl.Sprite _addSign; 

  static final num boxWidth = 100;
  static final num boxHeight = 60;
  static final num boxX = -boxWidth/2;
  static final num boxY = -boxHeight/2;
  
  NodeRenderer(Node node)//MindmapRenderer mindmapRenderer)
  { 
    //_mindmapRenderer = mindmapRenderer;
    _isFocus = false;
    //edges = <core.Edge>[];
    _node = node;
    
    var shape = new stagexl.Shape();
    shape.graphics.rectRound(boxX, boxY, boxWidth, boxHeight, 5, 5);
    shape.graphics.fillColor(stagexl.Color.Red);
    addChild(shape);
    
    var textfield = new stagexl.TextField();
    textfield.x = boxX + 5;
    textfield.y = boxY + 5;
    textfield.width = boxWidth - 10;
    textfield.height = boxHeight - 10;
    textfield.multiline = true;
    textfield.text = "Hallo Hansi";
    textfield.type = stagexl.TextFieldType.INPUT;
    textfield.textColor = stagexl.Color.Green;
    addChild(textfield);
    
    this.onMouseClick.listen((stagexl.MouseEvent me){
      //_mindmapRenderer.focusOnNode(this);
      me.stopPropagation(); //make sure the event does not reach the defocus event handler
    });
        
    this.onMouseDown.listen((stagexl.MouseEvent me){
      draggedObject = this;
    });
  }
  
  bool get isFocus => _isFocus;
  set isFocus (bool setFocus) {
    if(_isFocus == true && setFocus == false)
    {
      removeChild(_addSign);
      _addSign = null;
    }
    else if(_isFocus == false && setFocus == true)
    {
      _addSign = new stagexl.Sprite();
        _addSign.graphics.rect(boxX + boxWidth + 5, boxY, 20, 20);
        _addSign.graphics.fillColor(stagexl.Color.LightGreen);
        _addSign.onMouseClick.listen((stagexl.MouseEvent me){
          //_mindmapRenderer.controller.addChildNode();
          me.stopPropagation();
        });
      addChild(_addSign);
    }
    
    _isFocus = setFocus;
  }
}

class EdgeRenderer extends stagexl.Sprite {
  stagexl.Sprite line;
  Edge _edge;
  
  EdgeRenderer(_edge) {
    if(line != null){
      removeChild(line);
    }
    
    line = new stagexl.Sprite();
        
    line.graphics.beginPath();
    //line.graphics.moveTo(_edge.source.x, source.y);
    //line.graphics.lineTo(_edge.target.x, target.y);
    line.graphics.strokeColor(stagexl.Color.Green);
    line.graphics.closePath(); 
    addChild(line);
  }  
}
