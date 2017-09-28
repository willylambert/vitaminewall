      /**
    VITAMINE WALL 
    Copyright (C) 2016 Willy LAMBERT @willylambert

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
**/

class Dot{
  
  int _camX,_camY; // => coordinates from the Camera POV
  
  int _x, _y; // => coordinates from the Wall POV
  
  int _dotType; // => type : 0 => Not defined, 1 => Do Not Touch, 2 => To be Touched
  
  int _order; // => at level 2, dot must be touched in specific order
  
  int _dotSize;
  
  boolean _bTouched; // => true/false : touched
  boolean _bBlinking; // Used to animate a dot and detect its position
  boolean _bShow;
  boolean _bDetected;
  
  Dot(int x,int y, int dotType){
    _x = x;
    _y = y;
    _dotType = dotType;
    _bShow = true;
    _bDetected = false;
    _dotSize = Calibration.kDOT_SIZE;
  }

  void setCamCoordinates(int camX,int camY){
    _camX = camX;
    _camY = camY;
  }
  
  void setBlink(boolean bBlink){
    _bBlinking = bBlink;
  }

  void show(){
    _bShow = true;
  }

  void hide(){
    _bShow = false;
  }
  
  int getType(){
    return _dotType;
  }
  
  boolean isTouched(){
    return _bTouched;
  }
  
  void setFont(PFont font){
    g.textFont(font);
  }
  
  void setOrder(int order){
    _order = order;
  }
  
  void display(PGraphics g,boolean bDisplayOrder,boolean bShowRedDot){
    if(_bShow){
      if(_bBlinking){
        //change color each 300ms to try to detect his position
        g.fill(0,255-map(millis()%300,0,300,0,300),0,255-map(millis()%300,0,300,0,300));
        g.rect(_x, _y, Calibration.kDOT_SIZE, Calibration.kDOT_SIZE, 7);
      }else{
        if(_dotType==1 && bShowRedDot){
          //Do not touch area - red
          g.fill(255,0,0);
          g.rect(_x, _y, _dotSize, _dotSize, 7);
        }else{
          //Touch area - green
          g.fill(0,255,0);
          g.ellipse(_x+Calibration.kDOT_SIZE/2, _y+Calibration.kDOT_SIZE/2, _dotSize, _dotSize);
        }
      }      
      if(_bTouched && _dotSize>Calibration.kDOT_SIZE/10){
        _dotSize -= max(sqrt(Calibration.kDOT_SIZE*2 - _dotSize),0);
        //g.fill(255,255,255);
        //g.ellipse(_x+Calibration.kDOT_SIZE/2, _y+Calibration.kDOT_SIZE/2, _dotSize, _dotSize);
        //g.rect(_x+5, _y+5, _dotSize, _dotSize, 7);
      }
      if(bDisplayOrder){
        g.fill(255,255,255);
        g.text(_order, _x+30, _y+55);
      }
    }
  }

  void setDetected(boolean bDetected){
    _bDetected = bDetected;  
  }
  
    boolean getDetected(){
    return _bDetected;
  }
  
  void touch(){
    _bTouched = true;
  }
  
  void unTouch(){
    _bTouched = false;
  }

  int getX(){
    return _x;
  }
  
  int getY(){
    return _y;
  }

  int getXcam(){
    return _camX;
  }
  
  int getYcam(){
    return _camY;
  }

}  