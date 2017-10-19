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
  PShape _shapeReadyToGo;

  int _fullscreenMode; //0 => no fullscreen, 1 => display #1, 2 => display #2

  ArrayList<Dot> _dots = new ArrayList<Dot>();

  int _startTime;
  int _gameWonTime;
  boolean _bGameWon;
  boolean _bShowHallOfFame;
  boolean _bRecordNewWall;
  boolean _bReadyToGo;
  
  HallOfFame _hallOfFame;
  ReadyToGo _readyToGo;

  //used to display restart label during 2 sec. this variable is used as a countdown
  int _showRestartLabel; 

  int _remainingGreenDots;  

  int _level;

  TheWall(String calibrationImg, int fullscreenMode) {
    _calibrationImgPath = calibrationImg;   
    _fullscreenMode = fullscreenMode; 
    _showRestartLabel = 0;   
    _bShowHallOfFame = false;
    _bRecordNewWall = false;
    _bReadyToGo = false;    
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
    _readyToGo = new ReadyToGo(g);
  }

  void startGame() {
    println("Game Started");
    _bReadyToGo = false;
    _bShowHallOfFame = false;
    _bGameWon = false;
    _startTime = 0;
    _wallBuffer.textFont(_font);   
  }  
  
  /**
  * Record a new wall
  **/
  void newWall(){
    _bRecordNewWall = true;
    _dots = new ArrayList<Dot>();
    gData.getCurrentWall().setScreen(width,height);
}
  
  /**
  * Stop dots creation
  **/
  void endCreationWall(){
    _bRecordNewWall = false; 
    gData.setDots(_dots);
  }
  
  void mousePressed() {
    if (mouseButton == LEFT) {
      if(_dots.size()==0){
         //First dot is start Dot
        _dots.add(new Dot(mouseX-Calibration.kDOT_SIZE/2,mouseY-Calibration.kDOT_SIZE/2,0,null,null,_dots.size()));
      }else{
        //green dot
        _dots.add(new Dot(mouseX-Calibration.kDOT_SIZE/2,mouseY-Calibration.kDOT_SIZE/2,2,null,null,_dots.size()));
      }
    } else if (mouseButton == RIGHT) {
      //red dot
      _dots.add(new Dot(mouseX-Calibration.kDOT_SIZE/2,mouseY-Calibration.kDOT_SIZE/2,1,null,null,_dots.size()));
    }
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
  
  int getLevel(){
    return _level;
  }

  /**
   * When climber touch a do not touch area
   **/
  void restartGame() {
    _bReadyToGo = false;
    _showRestartLabel = 100;
    _bGameWon = false;
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

  void setDots(ArrayList<Dot> dots) {
   _dots = dots;   
  }

  void showCalibrationResult(ArrayList<Dot> dots) {
    println("showCalibrationResult");
    _bReadyToGo = true;

    _dots = dots;
    for (Dot dot : _dots) {
      dot.setFont(_font);
    }
    println("dots count",_dots.size());
}

  void displayHallOfFame(HallOfFame hall){
    _bShowHallOfFame = true;
    _hallOfFame = hall;    
  }
  
  void displayReadyToGo(){
    _bReadyToGo = true;
  }
  
  boolean displayHallOfFameIsDisplayed(){
    return _bShowHallOfFame;
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
    _wallBuffer.shapeMode(CENTER);

    if(_bRecordNewWall){
      _wallBuffer.fill(255,255,255);
      _wallBuffer.ellipse(mouseX, mouseY, Calibration.kDOT_SIZE, Calibration.kDOT_SIZE);
      for (Dot dot : _dots) {
        dot.display(_wallBuffer, true, true);
      }
    }else{
      if(_bReadyToGo){
        _readyToGo.display(_wallBuffer,frameCount);
      }else{
        if (!_bGameWon) {
          if (_dots != null && _dots.size()>0) {                         
            
            //First dot is used to trigger the timer
            if(_dots.get(0).isTouched() && _startTime==0){
              _startTime = millis();
            }
            
            for (Dot dot : _dots) {
              dot.display(_wallBuffer, (_level>1?true:false), (_level==3?false:true));
            }
    
          } else {
            if (_wallImg != null) {
              _wallBuffer.image(_wallImg, 0, 0);
            } else {
              //Welcome message
              _readyToGo.display(_wallBuffer,frameCount);
            }
          }
        
          //Print Timer
          if (_startTime!=0) {
            String msg = nf((millis()-_startTime)/1000., 3, 1);
            _wallBuffer.fill(255);
            _wallBuffer.text(msg, 10, 40);
          }
    
          if (_showRestartLabel>0) {
            String msg = "On recommence, le chrono tourne !";
            _showRestartLabel--;
            _wallBuffer.fill(255);            
            _wallBuffer.text(msg, (width/2)-_wallBuffer.textWidth(msg)/2, height/2);
          }
          
        }else{
           //Game Won !!
          String msg = "Bravo, pas mal... " + nf(_gameWonTime/1000., 0, 1) + " secondes !!";
          _wallBuffer.fill(255);
          _wallBuffer.text(msg, (width/2)-_wallBuffer.textWidth(msg)/2, height/4);
          
          if(_bShowHallOfFame){
            _hallOfFame.display(_wallBuffer);
          }
        }
      }
    }
    
    _wallBuffer.endDraw();
    image(_wallBuffer, 0, 0, width, height);
  }

}