part of mindmap;

class Relationship {
  Meme meme1;
  Meme meme2;
  Mindmap _mindmap;
  
  stagexl.Sprite line;
  
  Relationship(Mindmap mindmap, Meme meme1, Meme meme2){
    _mindmap = mindmap;
    this.meme1 = meme1;
    this.meme2 = meme2;
    render();
  }
  
  render(){
    if(line != null){
      _mindmap.stage.removeChild(line);
    }
    
    line = new stagexl.Sprite();
        
    line.graphics.beginPath();
    line.graphics.moveTo(meme1.x, meme1.y);
    line.graphics.lineTo(meme2.x, meme2.y);
    line.graphics.strokeColor(stagexl.Color.Green);
    line.graphics.closePath();
    _mindmap.stage.addChild(line);
  }
}