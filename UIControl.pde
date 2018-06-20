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

import processing.video.*;
import java.util.Map;

public class UIControl extends PApplet {
  
  VitaButton _btnCalibrate;
  VitaButton _btnGoLevel1;
  VitaButton _btnGoLevel2;
  VitaButton _btnGoLevel3;
  VitaButton _btnStop;
  VitaButton _btnDesignWall;
  VitaButton _btnSaveWall;
  
  // Sensivity threshold
  HScrollbar _redScrollBar;
  HScrollbar _greenScrollBar;
  HScrollbar _sensivityScrollBar;
  
  boolean _bGetPlayerName;
  String _playerName;
  
  // Use green and red stickers for calibration
  static final int kUSE_COLOR_STICKERS = -1;
     
  //Store the current selected wall index
  int _currentWallIndex;

  CameraView _camView;
  Calibration _calibration;
  TheWall _theWall;

  HallOfFame _hallOfFame;

  ArrayList<String> _camerasList;
  ArrayList<String> _wallList;
  
  ArrayList<VitaButton> _btnCameraList;
  ArrayList<VitaButton> _btnWallList;

  PFont _font;
  
  int _showStep;
  
  int _ctrlBckColor;

  UIControl(CameraView camView, TheWall theWall) {
    _camView = camView;
    _theWall = theWall;
    _camerasList = new ArrayList<String>();
    _wallList = new ArrayList<String>();
    
    _btnCameraList = new ArrayList<VitaButton>();
    _btnWallList = new ArrayList<VitaButton>();
    
    _bGetPlayerName = false;    
  }

  public void settings() {
    size(1024, 240);
  }

  public void setup() {
    frameRate(10);
    
    // Default font
    _font = gFont;    
    this.g.textFont(_font);
    this.g.textSize(15);

    // Calibrate
    _btnCalibrate = new VitaButton("Calibrate",125,70,100,20,this.g);
    _btnCalibrate.setVisible(false);
    
    // Color Sensivity 
    _redScrollBar = new HScrollbar(350,80,100,20,20,this.g);
    _redScrollBar.setVisible(false);
    _greenScrollBar = new HScrollbar(500,80,100,20,20,this.g);
    _greenScrollBar.setVisible(false);

    // Design Wall Button
    _btnDesignWall = new VitaButton("Design",230,70,100,20,this.g);
    _btnDesignWall.setVisible(false);

    // Save Wall Button
    _btnSaveWall = new VitaButton("Save Wall",335, 70,100, 20,this.g);
    _btnSaveWall.setVisible(false);    
          
    // Start Game button
    _btnGoLevel1 = new VitaButton("Go ! Level #1", 125, 100, 100, 20,this.g);
    _btnGoLevel1.setVisible(false);
    _btnGoLevel2 = new VitaButton("Go ! Level #2", 230, 100, 100, 20,this.g);
    _btnGoLevel2.setVisible(false);
    _btnGoLevel3 = new VitaButton("Go ! Level #3", 335, 100, 100, 20,this.g);
    _btnGoLevel3.setVisible(false);

    // Stop game button
    _btnStop = new VitaButton("End game",25, 130,100, 20,this.g);
    _btnStop.setVisible(false);
    
    _hallOfFame = new HallOfFame();

    loadData();
  }

  /**
  * Build cameras list - called from draw() as Capture.List() can take a while
  **/
  void loadCameras(){
    HashMap<String,Object> camerasFilteredList = new HashMap<String,Object>();
    String[] allCameras = Capture.list();

    for (int i=0; i<allCameras.length; i++) {
      String[] cameraInfo = split(allCameras[i], ',');
      camerasFilteredList.put(cameraInfo[0],i);
    }
    
    int btnCamXoffset = 125;
    for (Map.Entry camera : camerasFilteredList.entrySet()) {
      _camerasList.add(camera.getKey().toString());
      _btnCameraList.add(new VitaButton(camera.getKey().toString(),btnCamXoffset,0,220,20,this.g));
      btnCamXoffset += 220 + 10;
    }

    // Camera Detection Sensivity
    _sensivityScrollBar = new HScrollbar(btnCamXoffset+textWidth("Sensivity : "),10,100,20,20,this.g);
    _sensivityScrollBar.setValue(gData.getSensivity());    
  }

  void loadData(){
    //Walls loaded from data.json
    ArrayList<Wall> walls = gData.getWalls();
    _wallList.clear();
    int btnWallXoffset = 125;
    for (Wall wall : walls) {
      _wallList.add(wall.getName());
      _btnWallList.add(new VitaButton(wall.getName(),btnWallXoffset,40,50,20,this.g));
      btnWallXoffset += 55 + 10;
    }
  
    // Wall could be designed with colored holds
    // Green : area to touch
    // Red : forbidden area
    _btnWallList.add(new VitaButton("Color",btnWallXoffset,40,50,20,this.g));

  }

  void getPlayerName() {
    _bGetPlayerName = true; 
    _playerName = "";
     //<>//
    //Disable others //<>//
    _btnGoLevel1.setVisible(false);
    _btnGoLevel2.setVisible(false);
    _btnGoLevel3.setVisible(false);
    _btnStop.setVisible(false);
  } //<>//
 //<>//
  /**
  * Camera must see the entire wall
  * store calibration result in calibration object
  * then sent it both to theWall for display and to cameraVIew for analyse of movements
  **/
  void calibrateTheWall(){    
    int calibrationMode = (_currentWallIndex == kUSE_COLOR_STICKERS ? Calibration.kCALIBRATION_COLOR_STICKERS : Calibration.kCALIBRATION_VP); 
    _calibration = new Calibration(_camView,_theWall,calibrationMode);
    _calibration.calibrate();
  }

  void mousePressed(){
    
    // Camera select pressed
    int camIndex = 0;

    /** SELECT CAMERA **/
    VitaButton selectedBtn = null;
    for(VitaButton btn : _btnCameraList){
      if(btn.MouseIsOver()){
        selectedBtn = btn;
        _camView.setCamera(_camerasList.get(camIndex).toString());
        _sensivityScrollBar.setVisible(true);
        
      }
      camIndex++;
    }
     
    // Handle buttons toggling for camera selection
    if(selectedBtn!=null){
      for(VitaButton btn : _btnCameraList){
        btn.setSelected(false);
      }
      selectedBtn.setSelected(true);
    }
   
    /** SELECT WALL **/
    selectedBtn = null;
    int i = 0;
    for(VitaButton btn : _btnWallList){      
      if(btn.MouseIsOver()){
        selectedBtn = btn;
        // Last wall = wall designed by colored stickers
        if(i == _btnWallList.size() - 1 ){
        _currentWallIndex = kUSE_COLOR_STICKERS;
        _redScrollBar.setVisible(true);
        _greenScrollBar.setVisible(true);
        calibrateTheWall();
        }else{
          _currentWallIndex = i;        
          gData.setCurrentWall(_currentWallIndex);
          _theWall.setDots(gData.getCurrentWall().getDots());
        }
        break;
      }else{
        i++;
      }
    }
    
    // Handle buttons toggling for wall selection
    if(selectedBtn!=null){
      for(VitaButton btn : _btnWallList){
        btn.setSelected(false);
      }
      selectedBtn.setSelected(true);      
      // Design and calibration are only for VP mode
      if(_currentWallIndex != kUSE_COLOR_STICKERS){
        _btnCalibrate.setVisible(true);
        _btnDesignWall.setVisible(true);
        _btnGoLevel1.setVisible(false);
        _btnGoLevel2.setVisible(false);
        _btnGoLevel3.setVisible(false);         
      }
    }
        
    //Calibrate selected Wall
    if(_btnCalibrate.MouseIsOver()){     
      if(_currentWallIndex != kUSE_COLOR_STICKERS){
        calibrateTheWall();
        _btnGoLevel1.setVisible(true);
        _btnGoLevel2.setVisible(true);
        _btnGoLevel3.setVisible(true);
    }else{
        // We used colored stickers - save calibration result
        _theWall.setCalibrationMode(Calibration.kCALIBRATION_COLOR_STICKERS);
        _calibration.saveColorCalibrationResult();        
        _btnGoLevel1.setVisible(true);
      }
    }
    
    //Start Game !
    if(_btnGoLevel1.MouseIsOver() || _btnGoLevel2.MouseIsOver() || _btnGoLevel3.MouseIsOver()){
      int level = 0;      
      if(_btnGoLevel1.MouseIsOver()){
        level = 1;
      }else{
        if(_btnGoLevel2.MouseIsOver()){
          level = 2;
        }else{
          level = 3;
        }
      }
      _theWall.setLevel(level);
      _theWall.startGame();
      _camView.play();
      _btnStop.setVisible(true);
      _theWall.setInstructions("TOUCHE UNE PREMIERE PRISE POUR LANCER LE CHRONO");
    }
    
    //Stop Game
    if(_btnStop.MouseIsOver()){
      _camView.stopGame();
      _theWall.displayHallOfFame(_hallOfFame);
      _btnGoLevel1.setVisible(true);
      if(_currentWallIndex != kUSE_COLOR_STICKERS){
        _btnGoLevel2.setVisible(true);
        _btnGoLevel3.setVisible(true);
      }
    }
    
    //Design a new wall on current wall slot
    if(_btnDesignWall.MouseIsOver()){
      gData.newWall();
      _theWall.newWall();      
      _btnCalibrate.setVisible(false);
      _btnSaveWall.setVisible(true);    
    }
    
    //Save wall on current wall slot
    if(_btnSaveWall.MouseIsOver()){
      _theWall.endCreationWall();
      gData.getCurrentWall().setName("Wall #" + _currentWallIndex);
      gData.saveWall(_currentWallIndex);
      gData.loadData(); //reload data from json
      loadData(); //refresh wall list
      //Ready to run calibration
      _btnCalibrate.setVisible(true); 
      _btnSaveWall.setVisible(false);    
    }
    
  }

  /**
  * Handle scrollBar
  **/
  void mouseReleased(){
    // Set color sensivity
    _camView.setGoodHoldColorSensivity(_greenScrollBar.getValue());
    _camView.setDeadHoldColorSensivity(_redScrollBar.getValue());
    
    _camView.setDetectionSensivity(_sensivityScrollBar.getValue());
    
    // Save data - only for movement detection sensivity
    gData.setSensivity(_sensivityScrollBar.getValue());   
  }

  void keyPressed() {
    enterText(key,keyCode);
  }
  
  void enterText(char ch, int code){
    if(code != ENTER){
      _playerName += ch;
    }else{
      println(_playerName + " won in " + _theWall.getWonTime() + " ms");
      _hallOfFame.add(_theWall.getLevel(), _theWall.getWonTime(), _playerName);
      _theWall.displayHallOfFame(_hallOfFame);
      _btnGoLevel1.setVisible(true);
      _btnGoLevel2.setVisible(true);
      _btnGoLevel3.setVisible(true);
      _bGetPlayerName = false;
    }    
  }

  void draw() {    
    background(255);
    
    if(_camerasList.size()==0){
      background(255);
      textAlign(CENTER);   
      fill(0);
      text("Loading cameras...",width/2,height/2);
      if(frameCount==2){
        loadCameras();
      }
    }else{
      //Draw controls
      _btnCalibrate.display(mouseX,mouseY);
      _btnGoLevel1.display(mouseX,mouseY);
      _btnGoLevel2.display(mouseX,mouseY);
      _btnGoLevel3.display(mouseX,mouseY);
      _btnStop.display(mouseX,mouseY);
      _btnDesignWall.display(mouseX,mouseY);
      _btnSaveWall.display(mouseX,mouseY);  
      
      _redScrollBar.update(mouseX,mouseY,mousePressed);
      _redScrollBar.display();

      _greenScrollBar.update(mouseX,mouseY,mousePressed);
      _greenScrollBar.display();
      
      _sensivityScrollBar.update(mouseX,mouseY,mousePressed);
      _sensivityScrollBar.display();
      
      fill(0);
      text("Motion sensivity : ",_btnCameraList.size()*230+155,10);
            
      textAlign(LEFT);
      text("Capture Device : ",20,15);
      for(VitaButton btn : _btnCameraList){
        btn.display(mouseX,mouseY);
      }
      
      textAlign(LEFT);
      text("Wall : ",80,55);
      for(VitaButton btn : _btnWallList){
        btn.display(mouseX,mouseY);
      }
      
      if(_camView.getRedPickedDotColor()!=-1){
        fill(_camView.getRedPickedDotColor());
        rect(330,70,20,20);        
      }

      if(_camView.getGreenPickedDotColor()!=-1){
        fill(_camView.getGreenPickedDotColor());
        rect(480,70,20,20);        
      }
      
      if(_camView.getRedPickedDotColor()!=-1 && _camView.getGreenPickedDotColor()!=-1){
        _btnCalibrate.setVisible(true);
      }
      
      if(_bGetPlayerName){
        textAlign(LEFT);
        text("Enter your name : " + _playerName,5,140);        
      }
    }    
  }
}
