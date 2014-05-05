library mindmap_renderer;

import 'package:stagexl/stagexl.dart' as stagexl;
import "../core/mindmap_core.dart" as core;

stagexl.DisplayObject draggedObject;
num previousX;
num previousY;


class MindmapRenderer {
  stagexl.Stage _stage;
  stagexl.Stage get stage => _stage;

  core.MindmapController _controller;
  core.MindmapController get controller => _controller;
  
  core.Graph _focusedMeme;

  MindmapRenderer(var canvas, core.MindmapController controller){
    _controller = controller;
    
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
      _controller.addNode(me.stageX, me.stageY);
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
  
  focusOnNode(NodeRenderer nodeRenderer)
  {
    if(_stage.focus != null && _stage.focus is core.Node)
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

class NodeRenderer extends stagexl.Sprite implements core.Node
{    
  List<core.Edge> edges;  

  MindmapRenderer _mindmapRenderer;
  bool _isFocus;
  stagexl.Sprite _addSign; 

  static final num boxWidth = 100;
  static final num boxHeight = 60;
  static final num boxX = -boxWidth/2;
  static final num boxY = -boxHeight/2;
  
  NodeRenderer(MindmapRenderer mindmapRenderer)
  { 
    _mindmapRenderer = mindmapRenderer;
    _isFocus = false;
    edges = <core.Edge>[];
    
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
      _mindmapRenderer.focusOnNode(this);
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
          _mindmapRenderer.controller.addChildNode();
          me.stopPropagation();
        });
      addChild(_addSign);
    }
    
    _isFocus = setFocus;
  }
}

class EdgeRenderer {
  stagexl.Sprite line;
  
  render(){
    if(line != null){
      _mindmap.stage.removeChild(line);
    }
    
    line = new stagexl.Sprite();
        
    line.graphics.beginPath();
    line.graphics.moveTo(node1.x, node1.y);
    line.graphics.lineTo(node2.x, node2.y);
    line.graphics.strokeColor(stagexl.Color.Green);
    line.graphics.closePath();
    _mindmap.stage.addChild(line);
  }
}
