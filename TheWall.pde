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

  ControlP5 _cp5;
  Textfield _textFieldPlayer;

  String _calibrationImgPath;
  PImage _wallImg;

  PGraphics _wallBuffer;

  PFont _font;

  int _fullscreenMode; //0 => no fullscreen, 1 => display #1, 2 => display #2

  ArrayList<Dot> _dots = new ArrayList<Dot>();

  int _startTime;
  int _gameWonTime;
  boolean _bGameWon;
  boolean _bShowHallOfFame;
  
  HallOfFame _hallOfFame;

  //used to display restart label during 2 sec. this variable is used as a countdown
  int _showRestartLabel; 

  int _remainingGreenDots;

  int _level;

  TheWall(String calibrationImg, int fullscreenMode) {
    _calibrationImgPath = calibrationImg;   
    _fullscreenMode = fullscreenMode; 
    _showRestartLabel = 0;   
    _bShowHallOfFame = false;
  }

  public void settings() {
    switch(_fullscreenMode) {
    case 1 :
      fullScreen(1);
      break;
    case 2 :
      fullScreen(2);
      break;
    default :
      size(640, 480);
    }
  }

  void setup() {
    _wallImg = null;
    _dots = null;
    surface.setResizable(true);

    _font = createFont("Digital-7", 50);
    _wallBuffer = createGraphics(width, height);
    _cp5 = new ControlP5(this);
  }

  void startGame() {
    println("Game Started");
    _bShowHallOfFame = false;
    _bGameWon = false;
    _startTime = 0;
  }  
  
  int getStartTime(){
    return _startTime;
  }
  
 //Untouch all dots
  void resetDotStatus(){
    for (Dot dot : _dots) {
      dot.unTouch();
    }
  }

  void setLevel(int level) {
    _level = level;
  }

  /**
   * When climber touch a do not touch area
   **/
  void restartGame() {
    _showRestartLabel = 200;
    _bGameWon = false;
    resetDotStatus();
  }

  /**
   * When climber touch a do not touch area
   **/
  void gameWon() {
    println("Game Won :-)");
    _gameWonTime = millis()-_startTime;
    _bGameWon = true;
    
    gUIControl.getPlayerName();
  } 

  int getWonTime(){
    return _gameWonTime;
  }

  void showCalibrationImage() {
     _bShowHallOfFame = false;
    _bGameWon = false;
    _wallImg = loadImage(_calibrationImgPath);
    //Strech image to full screen
    println("resize", width, height);
    _wallImg.resize(width, height);
  }

  void showCalibrationResult(ArrayList<Dot> dots) {
    _dots = dots;
    for (Dot dot : _dots) {
      dot.setFont(_font);
    }
  }

  void displayHallOfFame(HallOfFame hall){
    _bShowHallOfFame = true;
    _hallOfFame = hall;    
  }

  void setRemainingGreenDots(int nb) {
    _remainingGreenDots = nb;
  }

  PImage getWallImg() {
    return _wallImg;
  }

  void draw() {
    _wallBuffer.beginDraw();
    _wallBuffer.background(0);

    if (!_bGameWon) {
      if (_dots != null) {      
        
        //First dot is used to trigger the timer
        if(_dots.get(0).isTouched() && _startTime==0){
          _startTime = millis();
        }
        
        for (Dot dot : _dots) {
          dot.display(_wallBuffer, (_level>1?true:false), (_level<2?true:false));
        }

      } else {
        if (_wallImg != null) {
          _wallBuffer.image(_wallImg, 0, 0);
        } else {
          //Welcome message
          _wallBuffer.textFont(_font);
          String msg = "Camera should fully see this screen"; 
          _wallBuffer.text(msg, (width/2)-_wallBuffer.textWidth(msg)/2, height/2);
          _wallBuffer.rect(0, 0, 50, 50);
          _wallBuffer.rect(width-50, 0, 50, 50);
          _wallBuffer.rect(width-50, height-50, 50, 50);
          _wallBuffer.rect(0, height-50, 50, 50);
        }
      }

      //Print Timer
      if (_startTime!=0) {
        String msg = nf((millis()-_startTime)/1000., 3, 1);
        _wallBuffer.fill(255);
        _wallBuffer.text(msg, 10, 40);

        /*
        msg = nf(_remainingGreenDots,2);
         _wallBuffer.fill(255);
         _wallBuffer.text(msg,width/2,30);
         */
      }

      if (_showRestartLabel>0) {
        String msg = ":-( Vite recommence, le chrono tourne !";
        _showRestartLabel--;
        _wallBuffer.fill(255);
        _wallBuffer.text(msg, (width/2)-_wallBuffer.textWidth(msg)/2, height/2);
      }
      
    }else{
       //Game Won !!
      String msg = "Bien joué ;-)  " + nf(_gameWonTime/1000., 3, 1);
      _wallBuffer.fill(255);
      _wallBuffer.text(msg, (width/2)-_wallBuffer.textWidth(msg)/2, height/4);
      
      if(_bShowHallOfFame){
        _hallOfFame.display(_wallBuffer);
      }
    }
    
    _wallBuffer.endDraw();
    image(_wallBuffer, 0, 0, width, height);
  }

}