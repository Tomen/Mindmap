library mindmap;

import 'dart:html' as html;
import 'package:stagexl/stagexl.dart' as stagexl;

part "meme.dart";
part "relationship.dart";

var stage;
stagexl.DisplayObject draggedObject;
num previousX;
num previousY;

void main() {
 
  print("hi");
  // setup the Stage and RenderLoop
  var canvas = html.querySelector('#stage');
  
  stage = new stagexl.Stage(canvas);
  stage.doubleClickEnabled = true;
  var renderLoop = new stagexl.RenderLoop();
  renderLoop.addStage(stage);
    
  var background = new stagexl.Shape();
  background.graphics.rect(0, 0, canvas.clientWidth, canvas.clientHeight);
  background.graphics.fillColor(stagexl.Color.LightGray);
  stage.addChild(background);

  stage.onMouseClick.listen((me){
    _focusOnMeme(null); //defocus current memes      
  });
  
  stage.onMouseDoubleClick.listen((me){
    _addMeme(me.stageX, me.stageY);
  });

  stage.onMouseMove.listen((stagexl.MouseEvent me){
    if(draggedObject != null){
      num deltaX = previousX - me.stageX;
      num deltaY = previousY - me.stageY;
      draggedObject.x -= deltaX;
      draggedObject.y -= deltaY;      
    }
    
    //MouseEvent deltaX and deltaY do not work as of now. Working around them
    previousX = me.stageX;
    previousY = me.stageY;
  });
  
  stage.onMouseUp.listen((stagexl.MouseEvent me){
    draggedObject = null;
  });
    
  _addMeme(100,100);  
}

Meme _addMeme(num x, num y){
  var meme = new Meme();
  meme.x = x;
  meme.y = y;
  stage.addChild(meme);  
  return meme;
}

_focusOnMeme(Meme meme)
{
  if(stage.focus != null && stage.focus is Meme)
  {
    stage.focus.isFocus = false;  
  }
  
  stage.focus = meme;
  
  if(meme != null)
  {
    meme.isFocus = true;
  }
}

