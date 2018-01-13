import processing.sound.*;

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

//Camera
CameraView gCamView;

//wall
TheWall gWall;

//Controls
UIControl gUIControl;

//Data - load data.json
Data gData;

SoundFile gGoSoundfile;
SoundFile gTouchSoundfile;
SoundFile gEndSoundfile;
SoundFile gWinSoundfile;
SoundFile gLooserSoundfile;

PImage gReadyToGoImage;
PShape gShapePill;

void setup(){  
  
  gGoSoundfile = new SoundFile(this, dataPath("go.wav"));
  gTouchSoundfile = new SoundFile(this, dataPath("touch.wav"));
  gEndSoundfile = new SoundFile(this, dataPath("end.wav"));
  gWinSoundfile = new SoundFile(this, dataPath("win.wav"));
  gLooserSoundfile = new SoundFile(this,dataPath("looser.wav"));
  
  //Camera feedback applet
  String[] camArgs = {"--location=0,0", "ClimbWall"};
  gCamView = new CameraView();
  PApplet.runSketch(camArgs, gCamView);
  
  //The Wall
  String[] wallArgs = {"--location="+(displayWidth-640)+",0", "ClimbWall"};
  gWall = new TheWall(2);
  PApplet.runSketch(wallArgs, gWall);
  
  //Controls
  String[] controlArgs = {"--location=0,500", "ClimbWall"};
  gUIControl = new UIControl(gCamView,gWall);
  PApplet.runSketch(controlArgs, gUIControl);
  
  //Data
  gData = new Data();
  
}