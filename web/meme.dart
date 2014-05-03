part of mindmap;

class Meme extends stagexl.Sprite
{
  bool _isFocus;
  stagexl.Sprite _addSign; 
  Mindmap _mindmap;
  List<Relationship> _relationships;
  
  static final num boxWidth = 100;
  static final num boxHeight = 60;
  static final num boxX = -boxWidth/2;
  static final num boxY = -boxHeight/2;
  
  Meme(Mindmap mindmap)
  { 
    _isFocus = false;
    _mindmap = mindmap;
    _relationships = <Relationship>[];
    
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
      _addSign = null;
    }
    else if(_isFocus == false && setFocus == true)
    {
      _addSign = new stagexl.Sprite();
        _addSign.graphics.rect(boxX + boxWidth + 5, boxY, 20, 20);
        _addSign.graphics.fillColor(stagexl.Color.LightGreen);
        _addSign.onMouseClick.listen((stagexl.MouseEvent me){
          _addChildMeme();
          me.stopPropagation();
        });
      addChild(_addSign);
    }
    
    _isFocus = setFocus;
  }
  
  List<Relationship> get relationships => _relationships;
  
  _addChildMeme(){
    Meme childMeme = _mindmap.addMeme(this.x, this.y + boxHeight + 5);
    _mindmap.addRelationship(this, childMeme);
  }
}