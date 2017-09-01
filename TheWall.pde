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
  
  PFont _font;
  
  int _fullscreenMode; //0 => no fullscreen, 1 => display #1, 2 => display #2
  
  ArrayList<Dot> _dots = new ArrayList<Dot>();
  
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
    if(_dots != null){
      background(0);
      for (Dot dot : _dots) {
        dot.display(g);
      }
    }else{
      if(_wallImg != null){
        image(_wallImg,0,0);
      }else{
        //Welcome message
        textFont(_font);
        String msg = "Move this window to the 2nd display and maximize it"; 
        text(msg,(width/2)-textWidth(msg)/2,height/2);
      }
    }
  }
  
  void showCalibrationResult(ArrayList<Dot> dots){
    _dots = dots;
  }
}