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
import processing.sound.*;

public class CameraView extends PApplet {

  // 640 x 480 resolution is enough for camera to do motion detection
  static final int kCAM_WIDTH = 640;
  static final int kCAM_HEIGHT = 480;
  
  // dots size in pixels
  static final int kDOT_SIZE = 20;
  
  // How different must a pixel be to be detected as a "motion" pixel
  float kTHRESHOLD = 50;
  float kSENSIVITY = 100; //number of pixels changed to light a dot
  
  DetectionResult _detectionResult;
  
  boolean _bEnableDetection;
  boolean _bPlay;
  int _nbUntouchedDots;
  int _nextDotOrderToTouch; //se for level 2 & 3 : dots must be touched in a specific order
  
  // Variable for capture device
  Capture mVideo;
   
  // Previous Frame
  PImage  mPrevFrame;
  // Current Frame
  PImage  mCurrFrame;  
  
  // Detection feedback
  PImage mFeedback;
  
  PGraphics mCamCtrl;
  
  //Use to disable detection during a short period of time after a dot is touched
  int mLastDetectionTime;
  
  ArrayList<Dot> _dots = new ArrayList<Dot>();
  
   public void settings(){
    size(kCAM_WIDTH*2, kCAM_HEIGHT);    
   }
  
   public void setup(){ 
    mVideo = new Capture(this, kCAM_WIDTH,kCAM_HEIGHT, 30);
    _detectionResult = new DetectionResult(0,0,0);

    mVideo.start();  
   
    mPrevFrame = createImage(mVideo.width,mVideo.height,RGB);
    mCurrFrame = createImage(mVideo.width,mVideo.height,RGB);
    mFeedback = createImage(mVideo.width,mVideo.height, RGB); 
    mCamCtrl = createGraphics(mVideo.width,mVideo.height);
   }
   
   PImage getCurrentFrame(){
     return mCurrFrame;
   }
   
   public void setCamera(String cameraName){     
    //we assume that video stream was already start in setup()
    mVideo.stop();
    
    mVideo = new Capture(this, kCAM_WIDTH,kCAM_HEIGHT, cameraName,30);
    mVideo.start();  
   }
 
  public void setDetection(boolean bStatus){
    _bEnableDetection = bStatus;
    _detectionResult = new DetectionResult(0,0,0);
    if(bStatus){
      _bPlay = false;
    }
  }
  
  public void play(){    
    _bEnableDetection = false;
   
    gWall.resetDotStatus();

    //How many dots to touch there is ?
    _nbUntouchedDots = this.getNbDotsToTouch();
    println(_nbUntouchedDots + " green dots");
    if(gWall.getLevel()>1){
      _nextDotOrderToTouch = 1;
    }else{
      _nextDotOrderToTouch = 0;//disabled
    }
    delay(1000);
    _bPlay = true;
  }
  
  private int getNbDotsToTouch(){
    int nbUntouchedDots = 0;
    for (Dot dot : _dots) {
      if(dot.getType()==2 && dot.getDetected()){
        nbUntouchedDots++;
      }
    }
    return nbUntouchedDots;
  }
  
  public DetectionResult getDetectionResult(){
    return _detectionResult;
  }

  private boolean dotIsActive(int x,int y){
    int loc = x + y*mVideo.width; // what is the 1D pixel location              
    color current = mCurrFrame.pixels[loc];      // what is the current color
    color previous = mPrevFrame.pixels[loc];     // what is the previous color
  
    // compare colors (previous vs. current)
    float r1 = red(current); float g1 = green(current); float b1 = blue(current);
    float r2 = red(previous); float g2 = green(previous); float b2 = blue(previous);
    float diff = dist(r1,g1,b1,r2,g2,b2);

    return (diff > kTHRESHOLD);
  }

  public void draw(){
    if(mVideo.available()){
     
      //Store previous video frame for comparison
      mPrevFrame.copy(mVideo,0,0,mVideo.width,mVideo.height,0,0,mVideo.width,mVideo.height); 

      mVideo.read();
            
      //Updated frame 
      mCurrFrame.copy(mVideo,0,0,mVideo.width,mVideo.height,0,0,mVideo.width,mVideo.height); 
            
      mPrevFrame.loadPixels(); 
      mCurrFrame.loadPixels();
      
      mCamCtrl.beginDraw();
      mCamCtrl.background(0);
      
      //For better performance, we don't analyse full screen when game is started
      if(!_bPlay){      
        //we divide image from cam in cells having dot size
        for(int xCell=0;xCell<kCAM_WIDTH;xCell+=kDOT_SIZE){
          for(int yCell=0;yCell<kCAM_HEIGHT;yCell+=kDOT_SIZE){
            int pixelsCount=0;
            for(int x=xCell;x<xCell+kDOT_SIZE;x++){
              for(int y=yCell;y<yCell+kDOT_SIZE;y++){                
                if(dotIsActive(x,y)) {    
                  pixelsCount++;
                  mFeedback.pixels[x + y*mVideo.width] = color(255);
                }else{
                  mFeedback.pixels[x + y*mVideo.width] = mPrevFrame.pixels[x + y*mVideo.width];   
                }
              }
            }
            if(pixelsCount > kSENSIVITY){
              //Highlight area detected - use or feedback
              mCamCtrl.fill(255);
              mCamCtrl.rect(xCell,yCell,kDOT_SIZE,kDOT_SIZE);
              if(_bEnableDetection){
                if(pixelsCount > _detectionResult.getBestScore()){                
                  _detectionResult.setResult(xCell, yCell, pixelsCount);
                  println("detection Result updated",xCell, yCell, pixelsCount);
                }                
              }
            }
          }
        }
      }
      
      if(_bPlay){
        //Game is started !!
                
        //We only analyse detected dots - for 
        boolean bDoNotTouchTouched = false;
        
        boolean bTimerIsStarted = (gWall.getStartTime()>0?true:false);
        
        int dotIdx = 0;
        for (Dot dot : _dots) {
          if(dot.getDetected()){
            //The first dot trigger timer
            if(!dot.isTouched() && bTimerIsStarted || dotIdx==0 && !bTimerIsStarted){
              //test if we have motion dot per dot
              int pixelsCount=0;
              for(int x=dot.getXcam();x<dot.getXcam()+kDOT_SIZE;x++){
                for(int y=dot.getYcam();y<dot.getYcam()+kDOT_SIZE;y++){
                   if(dotIsActive(x,y)) {    
                     pixelsCount++;
                   }                               
                }
              }
               
              if(pixelsCount > kSENSIVITY){
                println("TOUCHED dot cam",dot.getXcam(),dot.getYcam(),"has",pixelsCount);                 
                 //Start Play Game !!!
                if(dot.getType()==0){                  
                  dot.touch();
                  gGoSoundfile.play();
                }else{
                  if(dot.getType()==1){                    
                    dot.touch();
                    gLooserSoundfile.play();
                    bDoNotTouchTouched = true;
                    if(_nextDotOrderToTouch>0){
                      _nextDotOrderToTouch=1;
                    }
                  }else{
                    if(dot.getType()==2){
                      if(_nextDotOrderToTouch==0 || _nextDotOrderToTouch==dot.getOrder()){
                        dot.touch();
                        gTouchSoundfile.play();
                        _nbUntouchedDots--;                      
                        gWall.setRemainingGreenDots(_nbUntouchedDots);
                        if(_nextDotOrderToTouch>0){
                          _nextDotOrderToTouch++;
                        }
                        println("Next dot order",_nextDotOrderToTouch);
                        println("untouched dot count",_nbUntouchedDots);
                      }
                    }
                  }
                }
              }
            }  
          }
          dotIdx++;
        }
        
        if(bDoNotTouchTouched){
          //Restart game without reseting timer - or add a penality ?
          gWall.restartGame();
          delay(2000);
          for (Dot dot : _dots) {            
            dot.unTouch();    
          }
          _nbUntouchedDots = getNbDotsToTouch();
          gWall.setRemainingGreenDots(_nbUntouchedDots);
          delay(500);
        }
        
        //No more dot to touch : Game WON !!
        if(_nbUntouchedDots==0){
          delay(500); //let's dot touch animation time to run          
          gWall.gameWon();
          gEndSoundfile.play();
          _bPlay = false;
        }
   
      }
      
      mCamCtrl.endDraw();
      mFeedback.updatePixels();
      //Display current camera image for user feedback
      image(mFeedback,0,0,kCAM_WIDTH,kCAM_HEIGHT);      

      image(mCamCtrl,kCAM_WIDTH,0,kCAM_WIDTH,kCAM_HEIGHT);      
    }
  }

  
  void setDots(ArrayList<Dot> dots){
    _dots = dots;
  }
 
}