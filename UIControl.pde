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

import controlP5.*;
import processing.video.*;
import java.util.Map;

public class UIControl extends PApplet {

  ControlP5 _cp5;
  
  controlP5.Button _btnCalibrate;
  controlP5.Button _btnGoLevel1;
  controlP5.Button _btnGoLevel2;
  controlP5.Button _btnGoLevel3;
  controlP5.Button _btnStop;
  controlP5.Button _btnNewWall;
  controlP5.Button _btnSaveWall;
  controlP5.Slider _sliderDetectionThreshold;
  controlP5.Slider _sliderDetectionSensivity;
  
  ScrollableList _selCam;
  ScrollableList _selLevel;
  ScrollableList _selWall;
  
  Textfield _textFieldPlayer;
  Textfield _wallIndex;
  Textfield _wallName;

  CameraView _camView;
  Calibration _calibration;
  TheWall _theWall;

  HallOfFame _hallOfFame;

  ArrayList<String> _camerasList;
  ArrayList<String> _wallList;

  PFont _font;
  
  int _showStep;
  
  int _ctrlBckColor;

  UIControl(CameraView camView, TheWall theWall) {
    _camView = camView;
    _theWall = theWall;
    _camerasList = new ArrayList<String>();
    _wallList = new ArrayList<String>();
    
  }

  public void settings() {
    size(1024, 240);
  }

  public void setup() {
    _cp5 = new ControlP5(this);

    //default font
    _font = createFont("Digital-7", 15);

    //Sel Camera
    _selCam = _cp5.addScrollableList("sel-cam").setPosition(0, 10).setSize(220, 100).setBarHeight(20).setItemHeight(20).setType(ScrollableList.DROPDOWN).setOpen(false).setFont(_font);
    
    //Select wall
    _selWall = _cp5.addScrollableList("sel-wall").setPosition(0, 40).setSize(100, 100).setBarHeight(20).setItemHeight(20).setType(ScrollableList.DROPDOWN).setOpen(false).setFont(_font).setVisible(false);
   
   //Calibrate
   _btnCalibrate = _cp5.addButton("calibrate").setPosition(150, 70).setSize(100, 20).setFont(_font).setVisible(false);
   
   //Detection level
   _sliderDetectionThreshold = _cp5.addSlider("slider-threshold").setPosition(250,10).setSize(100,20).setRange(10,100).setValue(gData.getThreshold());
   
   //Sensivity : number of pixels changed to detect a touched dot
   _sliderDetectionSensivity = _cp5.addSlider("slider-sensivity").setPosition(450,10).setSize(100,20).setRange(10,CameraView.kDOT_SIZE*CameraView.kDOT_SIZE/2).setValue(gData.getSensivity());
   
    // Start Game button
    _btnGoLevel1 = _cp5.addButton("go-level-1").setPosition(0, 100).setSize(100, 20).setFont(_font).setVisible(false);
    _btnGoLevel2 = _cp5.addButton("go-level-2").setPosition(150, 100).setSize(100, 20).setFont(_font).setVisible(false);
    _btnGoLevel3 = _cp5.addButton("go-level-3").setPosition(300, 100).setSize(100, 20).setFont(_font).setVisible(false);

    // Stop game button
    _btnStop = _cp5.addButton("end-game").setPosition(450, 100).setSize(100, 20).setFont(_font).setVisible(true);

    // New Wall Button
    _btnNewWall = _cp5.addButton("new-wall").setPosition(150, 40).setSize(100, 20).setFont(_font).setVisible(false);

    // Save Wall Button
    _btnSaveWall = _cp5.addButton("save-wall").setPosition(300, 40).setSize(100, 20).setFont(_font).setVisible(false);
    _wallIndex = _cp5.addTextfield("wall-index").setPosition(450, 40).setSize(20, 20).setFont(_font).setVisible(false);
    _wallName = _cp5.addTextfield("wall-name").setPosition(450, 40).setSize(100, 20).setFont(_font).setVisible(false);

    _ctrlBckColor = _cp5.getController("go-level-1").getColor().getBackground();

    _textFieldPlayer = _cp5.addTextfield("player").setPosition(100, 130).setSize(200, 20).setFont(_font).setVisible(false);  
    Label label = _textFieldPlayer.getCaptionLabel(); 
    label.setText("Player : "); 
    label.align(ControlP5.LEFT_OUTSIDE, CENTER);
    label.getStyle().setPaddingLeft(-10);

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
    
    for (Map.Entry camera : camerasFilteredList.entrySet()) {
      _camerasList.add(camera.getKey().toString());
    }    
    
    _selCam.addItems(_camerasList);
  }

  void loadData(){
    //Walls loaded from data.json
    ArrayList<Wall> walls = gData.getWalls();
    _wallList.clear();
    _selWall.clear();
    for (Wall wall : walls) {
      _wallList.add(wall.getName());
    }
    _selWall.addItems(_wallList);

  }

  float getDetectionThreshold(){
    return _sliderDetectionThreshold.getValue();
  }

  float getDetectionSensivity(){
    return _sliderDetectionSensivity.getValue();
  }

  void getPlayerName() {
    //Get player name
    _textFieldPlayer.setVisible(true);
    _textFieldPlayer.setFocus(true);
    //Disable others
    _btnGoLevel1.setVisible(false);
    _btnGoLevel2.setVisible(false);
    _btnGoLevel3.setVisible(false);
    _btnStop.setVisible(false);
  }

  void controlEvent(ControlEvent theEvent) {
    if (theEvent.getController().getName() == "sel-cam") {
      int camIndex = (int)theEvent.getController().getValue();    
      _camView.setCamera(_camerasList.get(camIndex).toString());
      _selWall.setVisible(true);
      if(_wallList.size()==0){
        //No exisiting wall, add a new one
        _btnNewWall.setVisible(true);
      }
    }else{
      if (theEvent.getController().getName() == "sel-level") {
        int levelIndex = (int)theEvent.getController().getValue();      
        _theWall.setLevel(levelIndex);
        
      } else{      
        if (theEvent.getController().getName() == "calibrate") {
          println("calibrateTheWall");
          calibrateTheWall();
          // Now, btnGoLevel* are visible;
        }else{
          if (theEvent.getController().getName() == "end-game") {
            println("UIControl::controlEvent(): stop!");
            _camView.stopGame();
            _theWall.displayHallOfFame(_hallOfFame);
            _btnGoLevel1.show();
            _btnGoLevel2.show();
            _btnGoLevel3.show();
          }else{ //<>//
            if (theEvent.getController().getName() == "go-level-1") {
              println("UIControl::controlEvent(): go-level-1!");
              _btnStop.setVisible(true);               //<>//
              //_btnGoLevel1.setVisible(false);
              _btnGoLevel2.setVisible(false);
              _btnGoLevel3.setVisible(false);
              
              _theWall.setLevel(1);
              _theWall.startGame();
              _camView.play();
            }else{ //<>//
              if (theEvent.getController().getName() == "go-level-2") {
                println("UIControl::controlEvent(): go-level-2!");
                //_btnStop.setVisible(true);
                //_btnGoLevel1.setVisible(false);
                _btnGoLevel2.setVisible(false);
                //_btnGoLevel3.setVisible(false);
                _theWall.setLevel(2);              
                _theWall.startGame();
                _camView.play();
              }else{
                if (theEvent.getController().getName() == "go-level-3") {
                  println("UIControl::controlEvent(): go-level-3!");
                  //_btnStop.setVisible(true);
                  //_btnGoLevel1.setVisible(false);
                  //_btnGoLevel2.setVisible(false);
                  _btnGoLevel3.setVisible(false);
                  _theWall.setLevel(3);                
                  _theWall.startGame();
                  _camView.play();
                 }else{
                  if (theEvent.getController().getName() == "player") {        
                    println("UIControl::controlEvent(): player!");
                    if(_theWall.displayHallOfFameIsDisplayed()){
                      //Hall of fame is already displayed, show current wall to start a new round
                      _theWall.setDots(gData.getCurrentWall().getDots());
                    }else{
                      String playerName = _textFieldPlayer.getText();
                      println(playerName + " won in " + _theWall.getWonTime() + " ms");
                      _hallOfFame.add(_theWall.getLevel(), _theWall.getWonTime(), playerName);
                      _theWall.displayHallOfFame(_hallOfFame);
                      _btnGoLevel1.setVisible(true);
                      _btnGoLevel2.setVisible(true);
                      _btnGoLevel3.setVisible(true);
                      _textFieldPlayer.setVisible(false);
                    }
                  }else{
                    if (theEvent.getController().getName() == "new-wall") {    
                      println("UIControl::controlEvent(): new-wall!");
                      gData.newWall();
                      _theWall.newWall();
                      
                      _btnSaveWall.setVisible(true);
                      _wallIndex.setVisible(true);
                      _wallIndex.setText(nf(gData.getWalls().size()));
                      
                    }else{
                      if (theEvent.getController().getName() == "save-wall") {   
                        println("UIControl::controlEvent(): save-wall!");
                        _theWall.endCreationWall();
                        gData.getCurrentWall().setName("Wall #" + _wallIndex.getText());
                        gData.saveWall(Integer.parseInt(_wallIndex.getText()));
                        gData.loadData(); //reload data from json
                        loadData(); //refresh wall list                                            
                      }else{
                        if (theEvent.getController().getName() == "sel-wall") {
                          println("UIControl::controlEvent(): sel-wall!");
                          int wallIndex = (int)theEvent.getController().getValue();
                          gData.setCurrentWall(wallIndex);
                          _theWall.setDots(gData.getCurrentWall().getDots());
                          _btnCalibrate.setVisible(true);
                          _btnNewWall.setVisible(true);             
                          _btnGoLevel1.setVisible(false);
                          _btnGoLevel2.setVisible(false);
                          _btnGoLevel3.setVisible(false);
                          _btnStop.setVisible(false);
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        } 
      }
    }
  }  

  /**
  * Camera must see the entire wall
  * store calibration result in calibration object
  * then sent it both to theWall for display and to cameraVIew for analyse of movements
  **/
  void calibrateTheWall(){
    _calibration = new Calibration(_camView,_theWall);
    _calibration.calibrate();
    _btnGoLevel1.setVisible(true);
    _btnGoLevel2.setVisible(true);
    _btnGoLevel3.setVisible(true);
  }

  void setLock(Controller theController, boolean theValue) {
    theController.setLock(theValue);
    if(theValue) {
      theController.setColorBackground(color(100,100));
    } else {
      theController.setColorBackground(color(_ctrlBckColor));
    }
  }

  void draw() {
    if(_camerasList.size()==0){
      background(255);
      textAlign(CENTER);
      textFont(_font);
      fill(0);
      text("Loading cameras...",width/2,height/2);
      _cp5.hide();
      if(frameCount==2){
        loadCameras();
      }
    }else{
      _cp5.show();
      background(128);
    }    
  }
}