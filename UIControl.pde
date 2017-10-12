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
  controlP5.Button _btnNewWall;
  controlP5.Button _btnSaveWall;
  
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

  UIControl(CameraView camView, TheWall theWall) {
    _camView = camView;
    _theWall = theWall;
    _camerasList = new ArrayList<String>();
    _wallList = new ArrayList<String>();
    
  }

  public void settings() {
    size(640, 240);
  }

  public void setup() {
    _cp5 = new ControlP5(this);

    //default font
    _font = createFont("Digital-7", 15);

    //Sel Camera
    _selCam = _cp5.addScrollableList("sel-cam").setPosition(0, 10).setSize(100, 300).setItemHeight(20).setType(ScrollableList.DROPDOWN).setOpen(false).setFont(_font);
    
    //Select wall
    _selWall = _cp5.addScrollableList("sel-wall").setPosition(0, 40).setSize(100, 300).setItemHeight(20).setType(ScrollableList.DROPDOWN).setOpen(false).setFont(_font).setVisible(false);
   
   //Calibrate
   _btnCalibrate = _cp5.addButton("calibrate").setPosition(150, 70).setSize(100, 20).setFont(_font).setVisible(false);
   
    // Start Game button
    _btnGoLevel1 = _cp5.addButton("go-level-1").setPosition(0, 130).setSize(100, 20).setFont(_font).setVisible(false);
    _btnGoLevel2 = _cp5.addButton("go-level-2").setPosition(150, 130).setSize(100, 20).setFont(_font).setVisible(false);
    _btnGoLevel3 = _cp5.addButton("go-level-3").setPosition(300, 130).setSize(100, 20).setFont(_font).setVisible(false);

    // New Wall Button
    _btnNewWall = _cp5.addButton("new-wall").setPosition(150, 40).setSize(100, 20).setFont(_font).setVisible(false);

    // Save Wall Button
    _btnSaveWall = _cp5.addButton("save-wall").setPosition(250, 40).setSize(100, 30).setFont(_font).setVisible(false);
    _wallIndex = _cp5.addTextfield("wall-index").setPosition(400, 40).setSize(20, 20).setFont(_font).setVisible(false);
    _wallName = _cp5.addTextfield("wall-name").setPosition(450, 40).setSize(100, 20).setFont(_font).setVisible(false);

    _textFieldPlayer = _cp5.addTextfield("player").setPosition(100, 180).setSize(200, 20).setFont(_font).setVisible(false);  
    Label label = _textFieldPlayer.getCaptionLabel(); 
    label.setText("Player : "); 
    label.align(ControlP5.LEFT_OUTSIDE, CENTER);
    label.getStyle().setPaddingLeft(-10);

    _hallOfFame = new HallOfFame();

    String[] allCameras = Capture.list();
    
    HashMap<String,Object> camerasFilteredList = new HashMap<String,Object>();

    for (int i=0; i<allCameras.length; i++) {
      String[] cameraInfo = split(allCameras[i], ',');
      camerasFilteredList.put(cameraInfo[0],i);
    }

    for (Map.Entry camera : camerasFilteredList.entrySet()) {
      _camerasList.add(camera.getKey().toString());
    }    
    
    _selCam.addItems(_camerasList);

    loadData();
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

  void getPlayerName() {
    //Get player name
    _textFieldPlayer.setVisible(true);
    _textFieldPlayer.setFocus(true);
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
          _btnGoLevel1.setVisible(true);
          _btnGoLevel2.setVisible(true);
          _btnGoLevel3.setVisible(true);
        }else{
          if (theEvent.getController().getName() == "go-level-1") {
            _theWall.setLevel(1);            
            _theWall.startGame();
            _camView.play();
          }else{
            if (theEvent.getController().getName() == "go-level-2") {
              _theWall.setLevel(2);              
              _theWall.startGame();
              _camView.play();
            }else{
              if (theEvent.getController().getName() == "go-level-3") {
                _theWall.setLevel(3);                
                _theWall.startGame();
                _camView.play();
              }else{
                if (theEvent.getController().getName() == "player") {              
                  _textFieldPlayer.setVisible(true);
                  String playerName = _textFieldPlayer.getText();
                  println(playerName + " won in " + _theWall.getWonTime() + " ms");
                  _hallOfFame.add(_theWall.getLevel(), _theWall.getWonTime(), playerName);
                  _theWall.displayHallOfFame(_hallOfFame);
                }else{
                  if (theEvent.getController().getName() == "new-wall") {                              
                    gData.newWall();
                    _theWall.newWall();
                    
                    //_btnNewWall.setVisible(false);
                    _btnSaveWall.setVisible(true);
                    _wallIndex.setVisible(true);
                    _wallIndex.setText(nf(gData.getWalls().size()));
                    
                  }else{
                    if (theEvent.getController().getName() == "save-wall") {              
                      _theWall.endCreationWall();
                      gData.getCurrentWall().setName("Wall #" + _wallIndex.getText());
                      gData.saveWall(Integer.parseInt(_wallIndex.getText()));
                      //_btnNewWall.setVisible(true);
                      _btnSaveWall.setVisible(false);
                      _wallIndex.setVisible(false);
                      gData.loadData(); //reload data from json
                      loadData(); //refresh wall list
                    }else{
                      if (theEvent.getController().getName() == "sel-wall") {       
                        int wallIndex = (int)theEvent.getController().getValue();
                        println("sel-wall");
                        gData.setCurrentWall(wallIndex);
                        _theWall.setDots(gData.getCurrentWall().getDots());
                        _btnCalibrate.setVisible(true);
                        _btnNewWall.setVisible(true);                    
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

  void draw() {
    background(128);
  }
}