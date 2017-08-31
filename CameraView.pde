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

public class CameraView extends PApplet {

  // 640 x 480 resolution is enough for camera to do motion detection
  static final int kCAM_WIDTH = 640;
  static final int kCAM_HEIGHT = 480;
  
  // dots size in pixels
  static final int kDOT_SIZE = 20;
  
  // How different must a pixel be to be detected as a "motion" pixel
  float kTHRESHOLD = 35;
  float kSENSIVITY = 30; //number of pixels changed to light a dot
  
  DetectionResult _detectionResult;
  
  boolean _bEnableDetection;
  
  // Variable for capture device
  Capture mVideo;
   
  // Previous Frame
  PImage  mPrevFrame;
  // Current Frame
  PImage  mCurrFrame;  
  
  PGraphics mCamCtrl;
  
  // Detection feedback
  PImage mFeedback;

  //Use to disable detection during a short period of time after a dot is touched
  int mLastDetectionTime;

   public void settings(){
    size(kCAM_WIDTH, kCAM_HEIGHT);    
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
  }
  
  public DetectionResult getDetectionResult(){
    return _detectionResult;
  }

  public void draw(){
    if(mVideo.available()){
      mVideo.read();
      //Updated frame 
      mFeedback.copy(mVideo,0,0,mVideo.width,mVideo.height,0,0,mVideo.width,mVideo.height); 
      mFeedback.loadPixels();
      
      image(mFeedback,0,0,width,height);
      
      if(_bEnableDetection){
        //Store previous video frame for comparison
        mPrevFrame.copy(mVideo,0,0,mVideo.width,mVideo.height,0,0,mVideo.width,mVideo.height); 
        
        mVideo.read();
        
        //Updated frame 
        mCurrFrame.copy(mVideo,0,0,mVideo.width,mVideo.height,0,0,mVideo.width,mVideo.height); 
        
        mPrevFrame.loadPixels(); 
        mCurrFrame.loadPixels();         
        
        //we divide image from cam in cells having dot size
        for(int xCell=0;xCell<kCAM_WIDTH;xCell+=kDOT_SIZE){
          for(int yCell=0;yCell<kCAM_HEIGHT;yCell+=kDOT_SIZE){
            int pixelsCount=0;
            for(int x=xCell;x<xCell+kDOT_SIZE;x++){
              for(int y=yCell;y<yCell+kDOT_SIZE;y++){                
                int loc = x + y*mCurrFrame.width;            // what is the 1D pixel location
                color current = mCurrFrame.pixels[loc];      // what is the current color
                color previous = mPrevFrame.pixels[loc];     // what is the previous color
    
                // compare colors (previous vs. current)
                float r1 = red(current); float g1 = green(current); float b1 = blue(current);
                float r2 = red(previous); float g2 = green(previous); float b2 = blue(previous);
                float diff = dist(r1,g1,b1,r2,g2,b2);
                
                // Step 5, How different are the colors?
                if (diff > kTHRESHOLD) {    
                  mFeedback.pixels[loc] = color(255);
                  pixelsCount++;
                }
              }
            }
            if(pixelsCount > kSENSIVITY){              
              if(pixelsCount > _detectionResult.getBestScore()){
                println("cell ",xCell,"-",yCell," has ", pixelsCount);  
                _detectionResult.setResult(xCell, yCell, pixelsCount);                  
              }                
            }
          }
        }  
        image(mFeedback,0,0,width,height);
      }
    }
  }
 
/*  
  public void draw() {
    if(mVideo.available()) {
      mFeedback = createImage(mVideo.width,mVideo.height, RGB); 
      
      //Store previous video frame for comparison
      mPrevFrame.copy(mVideo,0,0,mVideo.width,mVideo.height,0,0,mVideo.width,mVideo.height); 
      
      mVideo.read();
      
      //Updated frame 
      mCurrFrame.copy(mVideo,0,0,mVideo.width,mVideo.height,0,0,mVideo.width,mVideo.height); 
      
      mPrevFrame.loadPixels(); 
      mCurrFrame.loadPixels();  
      
      if(bPlay && bEnableDetection){
         int pixelsCount=0;
         for(int x=gTblDots[gCurrentDot][2]*10;x<gTblDots[gCurrentDot][2]*10+10;x++){
           for(int y=gTblDots[gCurrentDot][3]*10;y<gTblDots[gCurrentDot][3]*10+10;y++){
              int loc = x + y*mCurrFrame.width;            // what is the 1D pixel location
              color current = mCurrFrame.pixels[loc];      // what is the current color
              color previous = mPrevFrame.pixels[loc];     // what is the previous color
  
              // compare colors (previous vs. current)
              float r1 = red(current); float g1 = green(current); float b1 = blue(current);
              float r2 = red(previous); float g2 = green(previous); float b2 = blue(previous);
              float diff = dist(r1,g1,b1,r2,g2,b2);
  
              // Step 5, How different are the colors?
              if (diff > kTHRESHOLD) {
                mFeedback.pixels[loc] = color(255);
                pixelsCount++;
              }
           }
         mLog.setValue("cell " + gTblDots[gCurrentDot][2] + "-"+gTblDots[gCurrentDot][3] + " has " +pixelsCount);
         }
         if(pixelsCount > kSENSIVITY){
           
           println("dot ",gCurrentDot, " at cell [",gTblDots[gCurrentDot][2],",",gTblDots[gCurrentDot][3],"] has ", pixelsCount);
           //Dot touched !!
           gTblDots[gCurrentDot][4] = 1;
           gDotSize = kDOT_SIZE*2;
           
           
           if(gCurrentDot==0){
             gGoSoundfile.play();
             gStartTime = millis();
           }else{
             gTouchSoundfile.play();
           }
           
           //Go to next dot
           gCurrentDot++;
           
           //Disable detection during 500 msc to allow drawing of next dot
           this.setDetection(false);           
         }
       }

      //After a dot detection, we wait for 500 ms to allow drawing of next dot
      if (!bEnableDetection && millis() - mLastDetectionTime >= 500) {
        bEnableDetection = true;
        println("detection enable");
      }      
      
      if(bChooseDots && bRecordDot){
        int bestScore = 0;
        //we divide screen in cells having dot size
        for(int xCell=0;xCell<64;xCell++){
          for(int yCell=0;yCell<48;yCell++){
            int pixelsCount=0;
            for(int x=xCell*10;x<xCell*10+10;x++){
              for(int y=yCell*10;y<yCell*10+10;y++){
                int loc = x + y*mCurrFrame.width;            // what is the 1D pixel location
                color current = mCurrFrame.pixels[loc];      // what is the current color
                color previous = mPrevFrame.pixels[loc];     // what is the previous color
    
                // compare colors (previous vs. current)
                float r1 = red(current); float g1 = green(current); float b1 = blue(current);
                float r2 = red(previous); float g2 = green(previous); float b2 = blue(previous);
                float diff = dist(r1,g1,b1,r2,g2,b2);
    
                // Step 5, How different are the colors?
                if (diff > kTHRESHOLD) {
                  mFeedback.pixels[loc] = color(255);
                  pixelsCount++;
                }
              }
            }
            if(pixelsCount > kSENSIVITY){              
              if(pixelsCount > bestScore){
                println("cell ",xCell,"-",yCell," has ", pixelsCount);         
                gTblDots[gNbDots][2] = xCell;
                gTblDots[gNbDots][3] = yCell;
                bestScore = pixelsCount;                  
              }                
            }
          }
        }
        if(bestScore>0){
          //dot detected
          bRecordDot  = false;
          gNbDots++;        
        }
      }        
      mFeedback.updatePixels();
      
      image(mVideo, 0, 0,mVideo.width,mVideo.height);
      image(mCamCtrl,mVideo.width,0,mVideo.width,mVideo.height);
    } 
  }
*/
}