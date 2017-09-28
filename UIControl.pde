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
  controlP5.Button _btnGo;
  ScrollableList _selCam;
  ScrollableList _selLevel;
  Textfield _textFieldPlayer;

  CameraView _camView;
  Calibration _calibration;
  TheWall _theWall;

  HallOfFame _hallOfFame;

  ArrayList<String> _camerasList;
  ArrayList<String> _levelList;

  PFont _font;

  UIControl(CameraView camView, TheWall theWall) {
    _camView = camView;
    _theWall = theWall;
    _camerasList = new ArrayList<String>();
    _levelList = new ArrayList<String>();
  }

  public void settings() {
    size(640, 240);
  }

  public void setup() {
    _cp5 = new ControlP5(this);

    //default font
    _font = createFont("Digital-7", 15);

    //Sel Camera
    _selCam = _cp5.addScrollableList("sel-cam").setPosition(0, 10).setSize(100, 300).setItemHeight(30).setType(ScrollableList.DROPDOWN).setOpen(false).setFont(_font);
    
    //Select level
    _selLevel = _cp5.addScrollableList("sel-level").setPosition(250, 10).setSize(100, 300).setItemHeight(30).setType(ScrollableList.DROPDOWN).setOpen(false).setFont(_font);

    _btnCalibrate = _cp5.addButton("calibrate").setPosition(width-210, 10).setSize(100, 30).setFont(_font).setVisible(true);

    // Start Game button
    _btnGo = _cp5.addButton("go").setPosition(width-105, 10).setSize(100, 30).setFont(_font).setVisible(false);

    _textFieldPlayer = _cp5.addTextfield("player").setPosition(100, 50).setSize(200, 20).setFont(_font);  
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
    
    //Levels
    _levelList.add("Level #1");
    _levelList.add("Level #2");
    _levelList.add("Level #3");
    _selLevel.addItems(_levelList);
  }

  void getPlayerName() {
    //Get player name
    _textFieldPlayer.setFocus(true);
  }

  void controlEvent(ControlEvent theEvent) {
    if (theEvent.getController().getName() == "sel-cam") {
      int camIndex = (int)theEvent.getController().getValue();    
      _camView.setCamera(_camerasList.get(camIndex).toString());
    }else{
      if (theEvent.getController().getName() == "sel-level") {
        int levelIndex = (int)theEvent.getController().getValue();      
        _theWall.setLevel(levelIndex);
      } else{      
        if (theEvent.getController().getName() == "calibrate") {
          calibrateTheWall();
        }else{
          if (theEvent.getController().getName() == "go") {
            _camView.play();
            _theWall.startGame();
          }else{
            if (theEvent.getController().getName() == "player") {              
              String playerName = _textFieldPlayer.getText();
              println(playerName + " won in " + _theWall.getWonTime() + " ms");
              _hallOfFame.add((int)theEvent.getController().getValue(), _theWall.getWonTime(), playerName);
              _theWall.displayHallOfFame(_hallOfFame);
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
    _btnGo.setVisible(true);
  }

  void draw() {
    background(128);
  }
}