library mindmap;

import 'dart:html' as html;
import 'package:stagexl/stagexl.dart' as stagexl;

part "meme.dart";
part "relationship.dart";

stagexl.DisplayObject draggedObject;
num previousX;
num previousY;

void main() {
  var canvas = html.querySelector('#stage');
 
  stagexl.Stage stage = new stagexl.Stage(canvas);
  stage.doubleClickEnabled = true;
  var renderLoop = new stagexl.RenderLoop();
  renderLoop.addStage(stage);
  
  Mindmap mindmap = new Mindmap(stage);
  
  var background = new stagexl.Shape();
  background.graphics.rect(0, 0, canvas.clientWidth, canvas.clientHeight);
  background.graphics.fillColor(stagexl.Color.LightGray);
  stage.addChild(background);

  stage.onMouseClick.listen((me){
    mindmap.focusOnMeme(null); //defocus current memes      
  });
  
  stage.onMouseDoubleClick.listen((me){
    mindmap.addMeme(me.stageX, me.stageY);
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
  
  mindmap.addMeme(100, 100);
}

class Mindmap {
  stagexl.Stage _stage;
  
  Mindmap(stage){
    _stage = stage;
  }
  
  Meme addMeme(num x, num y){
    var meme = new Meme(this);
    meme.x = x;
    meme.y = y;
    _stage.addChild(meme);  
    return meme;
  }
  
  Relationship addRelationship(Meme meme1, Meme meme2){
    Relationship relationship = new Relationship(meme1, meme2);
    
    return relationship;
  }
  
  focusOnMeme(Meme meme)
  {
    if(_stage.focus != null && _stage.focus is Meme)
    {
      Meme focus = _stage.focus;
      focus.isFocus = false;  
    }
    
    _stage.focus = meme;
    
    if(meme != null)
    {
      meme.isFocus = true;
    }
  }

}
