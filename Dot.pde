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
  
  int _camMinX,_camMinY,_camMaxX,_camMaxY; // => coordinates from the Camera POV
    
  int _x, _y; // => coordinates from the Wall POV
  
  int _dotType; // => type : 0 => Start, 1 => Do Not Touch, 2 => To be Touched
  
  int _order; // => at level 2, dot must be touched in specific order
  
  int _dotSize;

  PShape _shapePlay = loadShape(dataPath("play.svg"));
  PShape _shapeSkull = loadShape(dataPath("skull.svg"));
  PShape _shapeDiamond = loadShape(dataPath("pill.svg"));
  PShape _shapeTouch;
  PShape _shapeUnTouch;
  
  boolean _bTouched; // => true/false : touched
  boolean _bBlinking; // Used to animate a dot and detect its position
  boolean _bShow;
  boolean _bDetected;
  
  // Used to display the touch effect during few sec.
  int _touchTime;
  
  boolean _bBackgroundTouchEffect;
  
  /**
  * @param int x wall coordinate
  * @param int y wall coordinate
  * @param int dotType : 1 = red, 2 = green
  **/
  Dot(int x,int y, int dotType,PShape shapeUnTouch,PShape shapeTouch, int order,boolean bBackgroundTouchEffect){
    _x = x;
    _y = y;
    _dotType = dotType;
    this.setOrder(order);
    _bShow = true;
    _bDetected = false;
    _dotSize = Calibration.kDOT_SIZE*2;
    _shapeUnTouch = shapeUnTouch;
    _shapeTouch = shapeTouch;
    _bBackgroundTouchEffect = bBackgroundTouchEffect;
    
    if(dotType==0){
      _shapeUnTouch = _shapePlay;
    }    
  }

  /**
  * Add flashing color effect when a hold is tapped
  */
  void setBackgroundTouchEffect(boolean bBackgroundTouchEffect){
    _bBackgroundTouchEffect = bBackgroundTouchEffect;
  }

  void setCamCoordinates(int camX,int camY, int camMaxX, int camMaxY){
    _camMinX = camX;
    _camMinY = camY;
    _camMaxX = camMaxX;
    _camMaxY = camMaxY;
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
   
  void setOrder(int order){
    _order = order;
  }
  
  int getOrder(){
    return _order;
  }
  
  JSONObject getJSON(){
    JSONObject json = new JSONObject();
    
    json.setInt("x",_x);
    json.setInt("y",_y);
    json.setInt("type",_dotType);
    json.setInt("order",_order);
    
    return json;
  }
  
  void display(PGraphics g,boolean bDisplayOrder,boolean bShowRedDot){
    if(_bShow){      
      if(_bBlinking){
        //change color each 300ms to try to detect his position
        g.fill(255,255,255,255-map(millis()%300,0,300,0,300));
        g.rect(_x, _y, Calibration.kDOT_SIZE, Calibration.kDOT_SIZE, 7);
      }else{
        // Do not tap hold
        if(_dotType==1 && bShowRedDot){          
            if(millis() - _touchTime < 1500){
              if(_bBackgroundTouchEffect){
                g.background(255,0,0);
              }
              g.fill(255,0,0);
              g.ellipse(_x+Calibration.kDOT_SIZE/2, _y+30, Calibration.kDOT_SIZE-20, Calibration.kDOT_SIZE-20);
            }else{
            g.fill(0);  
          }
          g.shape(_shapeSkull,_x+Calibration.kDOT_SIZE/2,_y+Calibration.kDOT_SIZE/2,Calibration.kDOT_SIZE,Calibration.kDOT_SIZE);
        }else{          
          // hold to tap
          if(_dotType==2){
            g.fill(255,255,255);
            if(_bTouched){
              // Extend + Collapse effect 
              if(_dotSize>0){
                if(_bBackgroundTouchEffect){
                  g.background(0,255,0);
                }
                _dotSize -= sqrt(Calibration.kDOT_SIZE*4 - _dotSize/4)/2;
                g.ellipse(_x+Calibration.kDOT_SIZE/2, _y+Calibration.kDOT_SIZE/2, _dotSize, _dotSize);                
              }                    
            }else{
              g.ellipse(_x+Calibration.kDOT_SIZE/2, _y+Calibration.kDOT_SIZE/2, Calibration.kDOT_SIZE, Calibration.kDOT_SIZE);
            }            
          }
        }
        
        if(_shapeUnTouch!=null && !_bTouched){
          g.shape(_shapeUnTouch,_x+Calibration.kDOT_SIZE/2,_y+Calibration.kDOT_SIZE/2,Calibration.kDOT_SIZE,Calibration.kDOT_SIZE);
        }
      }      
      //Order could be only displayed for good hold
      if(_dotType==2 && !_bTouched && this.getOrder()>0){
        g.fill(0);
        if(bDisplayOrder){
          g.textSize(50);
          g.textAlign(CENTER,CENTER);        
          g.text(str(this.getOrder()), _x, _y,Calibration.kDOT_SIZE,Calibration.kDOT_SIZE);
        }
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
    print("Hold # " + _order + " touched");
    _touchTime = millis();
    _bTouched = true;
  }
  
  void unTouch(){
    _bTouched = false;
    _dotSize = Calibration.kDOT_SIZE*2;
  }

  int getX(){
    return _x;
  }
  
  int getY(){
    return _y;
  }

  int getXcam(){
    return _camMinX;
  }
  
  int getYcam(){
    return _camMinY;
  }

  int getXcamMax(){
    return _camMaxX;
  }
  
  int getYcamMax(){
    return _camMaxY;
  }

}  
