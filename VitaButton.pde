class VitaButton {
  String _label;
  float _x;    // top left corner x position
  float _y;    // top left corner y position
  float _w;    // width of button
  float _h;    // height of button
  
  int _mouseX;
  int _mouseY;
  
  boolean _visible;
  boolean _selected;
  
  float _xLabel;
  float _yLabel;
  
  PGraphics _g;
  
  VitaButton(String labelB, float xpos, float ypos, float widthB, float heightB,PGraphics g) {
    _label = labelB;
    _x = xpos;
    _y = ypos;
    _w = widthB;
    _h = heightB;
    _g = g;
    _visible = true;
    _xLabel = _x+_w/2-textWidth(_label)/2;
    _yLabel = _h/2;
  }
  
  void setVisible(boolean visible){
    _visible = visible;
  }

  void setSelected(boolean selected){
    _selected = selected;
  }
  
  void display(int mx,int my) {
    if(_visible){
      _mouseX = mx;
      _mouseY = my;
      
      if (MouseIsOver() || _selected) {
        _g.fill(218);
      }else{
        _g.fill(120);
      }
      
      _g.stroke(141);
      _g.rect(_x, _y, _w, _h, 10);
      _g.fill(0);
      _g.text(_label, _xLabel , _yLabel);
    }
  }
  
  boolean MouseIsOver() {
    if (_mouseX > _x && _mouseX < (_x + _w) && _mouseY > _y && _mouseY < (_y + _h)) {
      return true;
    }
    return false;
  }
}
