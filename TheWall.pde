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

class TheWall extends PApplet {
  
  String _calibrationImgPath;
  PImage _wallImg;
  
  PGraphics _wallBuffer;
  
  PFont _font;
  
  int _fullscreenMode; //0 => no fullscreen, 1 => display #1, 2 => display #2
  
  ArrayList<Dot> _dots = new ArrayList<Dot>();
  
  int _startTime;
  
  TheWall(String calibrationImg,int fullscreenMode){
    _calibrationImgPath = calibrationImg;   
    _fullscreenMode = fullscreenMode;    
  }
  
  public void settings(){
    switch(_fullscreenMode){
      case 1 :
        fullScreen(1);
        break;
      case 2 :
         fullScreen(2);
         break;
      default :
         size(640,480);
    }
  }
    
  void setup(){
    _wallImg = null;
    _dots = null;
    surface.setResizable(true);
    
    _font = createFont("Digital-7",30);
    _wallBuffer = createGraphics(width,height);
  }
  
  void startTimer(){
    _startTime = millis();
  }
 
  void showCalibrationImage(){
    _wallImg = loadImage(_calibrationImgPath);
    //Strech image to full screen
    println("resize",width,height);
    _wallImg.resize(width,height);
  }
    
  PImage getWallImg(){
    return _wallImg;
  }
    
  void draw(){
    _wallBuffer.beginDraw();
    _wallBuffer.background(0);
    if(_dots != null){      
      for (Dot dot : _dots) {
        dot.display(_wallBuffer);
      }
    }else{
      if(_wallImg != null){
        _wallBuffer.image(_wallImg,0,0);
      }else{
        //Welcome message
        _wallBuffer.textFont(_font);
        String msg = "Move this window to the 2nd display and maximize it"; 
        _wallBuffer.text(msg,(width/2)-textWidth(msg)/2,height/2);
      }
    }
    
    if(_startTime!=0){
      String msg = nf((millis()-_startTime)/1000.,3,1);
      _wallBuffer.fill(255);
      _wallBuffer.text(msg,0,30);
    }
    
    _wallBuffer.endDraw();
    image(_wallBuffer,0,0,width,height);
  }
  
  void showCalibrationResult(ArrayList<Dot> dots){
    _dots = dots;
  }
}