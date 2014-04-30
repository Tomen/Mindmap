import 'dart:html' as html;
import 'package:stagexl/stagexl.dart' as stagexl;

var stage;
html.ParagraphElement textfield;
stagexl.DisplayObject draggedObject;
num previousX;
num previousY;

void main() {
 
  print("hi");
  // setup the Stage and RenderLoop
  var canvas = html.querySelector('#stage');
  textfield = html.querySelector("#textfield");
  
  stage = new stagexl.Stage(canvas);
  var renderLoop = new stagexl.RenderLoop();
  renderLoop.addStage(stage);
    
  var background = new stagexl.Shape();
  background.graphics.rect(0, 0, canvas.clientWidth, canvas.clientHeight);
  background.graphics.fillColor(stagexl.Color.LightGray);
  stage.addChild(background);

  stage.onMouseClick.listen((me){
    if(stage.focus != null){
      stage.focus = null; //defocus current memes      
    }
    else {
      _addMeme(me);
    }
    
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
  //stage.onTextInput.listen(_onTextInput);
  //html.document.onKeyDown.listen(_onKeyDown);
    
  
  var meme = new Meme();
  meme.x = 100;
  meme.y = 100;
  stage.addChild(meme);
}

_addMeme(stagexl.MouseEvent me)
{
  var meme = new Meme();
  meme.x = me.localX;
  meme.y = me.localY;
  stage.addChild(meme);    
}


class Meme extends stagexl.Sprite
{
  String text;
  
  Meme()
  {
    num width = 100;
    num height = 60;
    num x = -width/2;
    num y = -height/2;
    
    var shape = new stagexl.Shape();
    shape.graphics.rectRound(x, y, width, height, 5, 5);
    shape.graphics.fillColor(stagexl.Color.Red);
    addChild(shape);
    
    var textfield = new stagexl.TextField();
    textfield.x = x + 5;
    textfield.y = y + 5;
    textfield.width = width - 10;
    textfield.height = height - 10;
    textfield.multiline = true;
    textfield.text = "Hallo Hansi";
    textfield.type = stagexl.TextFieldType.INPUT;
    textfield.textColor = stagexl.Color.Green;
    addChild(textfield);
    
    this.onMouseClick.listen((stagexl.MouseEvent me){
      stage.focus = me.target;
      me.stopPropagation(); //make sure the event does not reach the defocus event handler
    });
        
    this.onMouseDown.listen((stagexl.MouseEvent me){
      draggedObject = this;
    });
    
  }
}