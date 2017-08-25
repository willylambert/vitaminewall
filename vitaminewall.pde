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
import java.util.Map;

//Camera
CameraView gCamView;

//wall
TheWall gWall;

//Controls
UIControl gUIControl;

ControlP5 _cp5;
controlP5.Button _btnCalibrate;
controlP5.Button _btnGo;
controlP5.Button _btnWindow;
controlP5.Button _btnFullScreen1;
controlP5.Button _btnFullScreen2;
ScrollableList _selCam;

CameraView _camView;
Calibration _calibration;
TheWall _theWall;

ArrayList<String> _camerasList;

PFont _font;


void setup(){  
  //Camera feedback applet
  String[] camArgs = {"--location=0,0", "ClimbWall"};
  gCamView = new CameraView();
  PApplet.runSketch(camArgs, gCamView);
  
  //Wall applet
  String[] wallArgs = {"--location="+(displayWidth-640)+",0", "ClimbWall"};
  gWall = new TheWall("C:\\Users\\w.lambert.DURAND\\Documents\\GitHub\\vitaminewall\\wall1.png",0);
  PApplet.runSketch(wallArgs, gWall);
  
  //Wall control - will then launch "the Wall" on fullscreen display
  String[] controlArgs = {"--location=0,500", "ClimbWall"};
  gUIControl = new UIControl(gCamView,gWall);
  PApplet.runSketch(controlArgs, gUIControl);
}