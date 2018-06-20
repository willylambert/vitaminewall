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
  
  PImage _wallImg;

  PGraphics _wallBuffer;

  PFont _font;
  PShape _shapeReadyToGo;

  int _fullscreenMode; //0 => no fullscreen, 1 => display #1, 2 => display #2

  ArrayList<Dot> _dots = new ArrayList<Dot>();

  // Calibration could be done by displaying dots on wall with VP (Calibration.kCALIBRATION_VP)
  // or by colored stickers : green = hold to touch / red = hold to avoid (Calibration.kCALIBRATION_COLOR_STICKERS)
  int _calibrationMode;

  int _startTime;
  int _gameWonTime;
  boolean _bGameWon;
  boolean _bShowHallOfFame;
  boolean _bRecordNewWall;
  boolean _bReadyToGo;
  
  HallOfFame _hallOfFame;
  ReadyToGo _readyToGo;

  // Used to display restart label during 2 sec. this variable is used as a countdown
  int _showRestartLabel; 

  int _remainingGreenDots;  

  int _level;
  
  // Instructions for player
  String _instructions = "";

  TheWall(int fullscreenMode) {  
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
    frameRate(60);
    _wallImg = null;
    _dots = null;
    surface.setResizable(true);
    
    _wallBuffer = createGraphics(width, height);
    _font = gFont;    
    _readyToGo = new ReadyToGo(g);
  }

  void startGame() {
    println("Game Started");
    _bReadyToGo = false;
    _bShowHallOfFame = false;
    _bGameWon = false;
    _startTime = 0;    
  } 

  void setCalibrationMode(int calibrationMode){
    _calibrationMode = calibrationMode;    
  }
  
  void setInstructions(String instructions){
    _instructions = instructions;
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
  * Stop dots creation - Stop to record a new wall
  **/
  void endCreationWall(){
    _bRecordNewWall = false; 
    gData.setDots(_dots);
  }

  /**
  * If TheWall window as focus, forward input to control window
  **/
  void keyPressed() {
    gUIControl.enterText(key,keyCode);
  }  
  
  void mousePressed() {
    if (mouseButton == LEFT) {
      if(_dots.size()==0){
         //First dot is start Dot
        _dots.add(new Dot(mouseX-Calibration.kDOT_SIZE/2,mouseY-Calibration.kDOT_SIZE/2,0,null,null,_dots.size(),false));
      }else{
        //green dot (pills)
        _dots.add(new Dot(mouseX-Calibration.kDOT_SIZE/2,mouseY-Calibration.kDOT_SIZE/2,2,null,null,_dots.size(),false));
      }
    } else if (mouseButton == RIGHT) {
      //red dot (skull)
      _dots.add(new Dot(mouseX-Calibration.kDOT_SIZE/2,mouseY-Calibration.kDOT_SIZE/2,1,null,null,_dots.size(),false));
    }
  }
  
  int getStartTime(){
    return _startTime;
  }
  
  void startTimer(){
    print("Start Timer");
    _startTime = millis();
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
    if(_calibrationMode==Calibration.kCALIBRATION_VP){
      _showRestartLabel = 100;
    }
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
    _bShowHallOfFame = false;
    _bGameWon = false;
    _startTime = 0;
  }

  /**
  * Retrieve screen height
  **/
  float getHeight(){
    return height;
  }

  /**
  * Retrieve screen width
  **/
  float getWidth(){
    return width;
  }

  void showCalibrationResult(ArrayList<Dot> dots) {
    println("showCalibrationResult");
    _bReadyToGo = false;

    _dots = dots;
    println("dots count",_dots.size());
}

  void displayHallOfFame(HallOfFame hall){
    _bShowHallOfFame = true;
    _hallOfFame = hall;    
  }
   
  void displayReadyToGo(){
    _bShowHallOfFame = false;
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
    background(0);
    textAlign(LEFT,TOP);
    shapeMode(CENTER);
    textFont(_font);
    
    if(_bRecordNewWall){
      fill(255,255,255);
      ellipse(mouseX, mouseY, Calibration.kDOT_SIZE, Calibration.kDOT_SIZE);
      for (Dot dot : _dots) {
        dot.display(g, true, true);
      }
    }else{
      if(_bReadyToGo){
        _readyToGo.display(g,frameCount);
      }else{
        if(!_bGameWon) {
          //Game is running !

          //Print Timer or instructions
          if (_startTime!=0) {
            _instructions = nf((millis()-_startTime)/1000., 3, 1); 
            if(_calibrationMode == Calibration.kCALIBRATION_COLOR_STICKERS){
              textSize(150);
            }
          }
          fill(255);
          text(_instructions, 10, 5);
          
          if(_dots != null && _dots.size()>0){                         
                        
            for (Dot dot : _dots) {
              dot.display(g, (_level>1?true:false), (_level==3?false:true));
            }
    
          }else{
            if (_wallImg != null) {
              image(_wallImg, 0, 0);
            } else {
              //Welcome message
              _readyToGo.display(g,frameCount);
            }
          }
            
          if (_showRestartLabel>0) {
            String msg = "On recommence, le chrono tourne !";
            _showRestartLabel--;
            fill(255);            
            text(msg, (width/2)-textWidth(msg)/2, height/2);
          }
          
        }else{
           //Game Won !!
          String msg = "Bravo, pas mal... " + nf(_gameWonTime/1000., 0, 1) + " secondes !!";
          fill(255);
          text(msg, (width/2)-textWidth(msg)/2, height/4);          
        }
      }
    }
    
    if(_bShowHallOfFame){
      fill(255);
      _hallOfFame.display(g);
    }
    
  }

}
