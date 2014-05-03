part of mindmap;

class Meme extends stagexl.Sprite
{
  bool _isFocus;
  static stagexl.Sprite _addSign; 
  
  Meme(Mindmap mindmap)
  { 
    num width = 100;
    num height = 60;
    num x = -width/2;
    num y = -height/2;
    
    if(_addSign == null){
      _addSign = new stagexl.Sprite();
      _addSign.graphics.rect(x + width + 5, y, 20, 20);
      _addSign.graphics.fillColor(stagexl.Color.LightGreen);
      _addSign.onMouseClick.listen((stagexl.MouseEvent me){
        mindmap.addMeme(me.stageX, me.stageY + height + 5);
        me.stopPropagation();
      });
    }
    
    _isFocus = false;
    
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
      mindmap.focusOnMeme(this);
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
    }
    else if(_isFocus == false && setFocus == true)
    {
      addChild(_addSign);
    }
    
    _isFocus = setFocus;
  }
}