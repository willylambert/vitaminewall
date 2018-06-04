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
  
  // calibration : pick color on camera feedback  
  static final int kPICK_MOTION_DOT = 0;
  static final int kPICK_RED_DOT = 1;
  static final int kPICK_GREEN_DOT = 2;
   
  int _redDotPickedColor = -1;
  int _greenDotPickedColor = -1;
  
  // Calibration could be done by displaying dots on wall with VP (kCALIBRATION_VP)
  // or by colored stickers : green = touch dot / red = not touch dot (kCALIBRATION_COLOR_STICKERS)
  int _calibrationMode;
  
  // How different must a pixel be to be detected as a "motion" pixel
  float _detectionThreshold;
  
  float _detectionSensivity;
  
  // "Good" : area's color to touch
  float _goodHoldColorDetectionSensivity;
  // "Dead" : aera's color to avoid
  float _deadHoldColorDetectionSensivity;
  
  // Used to clean detected dots every X sec
  int _timer;
    
  // Store and clean detection results  
  DetectionResult _detectionResult;
  
  boolean _bEnableDetection;
  boolean _bPlay;
  int _nbUntouchedDots;
  int _nextDotOrderToTouch; //se for level 2 & 3 : dots must be touched in a specific order
  
  // Instructions message to be displayed on "TheWall"
  String _instructionMessage = "";
  
  // Capture device
  Capture _video;
  
  PFont _font;
   
  // Previous Frame
  PImage  mPrevFrame;
  // Current Frame
  PImage  mCurrFrame;  
  
  // Detection feedback
  PImage mFeedback;
  
  // Video feedback + detection feedback
  PGraphics mCamCtrl;
   
  // Used to pause game - value is frameCount before restart detection
  int _pauseCount;
  
  ArrayList<Dot> _dots = new ArrayList<Dot>();
  
  Movie _goSoundfile;
  Movie _touchSoundfile;
  Movie _endSoundfile;
  Movie _winSoundfile;
  Movie _looserSoundfile;
  
  
   public void settings(){
    size(kCAM_WIDTH*2, kCAM_HEIGHT);
    _goSoundfile = new Movie(this, gDataPath + "\\go.wav");
    _touchSoundfile = new Movie(this, gDataPath + "\\touch.wav");
    _endSoundfile = new Movie(this, gDataPath + "\\end.wav");
    _winSoundfile = new Movie(this, gDataPath + "\\win.wav");
    _looserSoundfile = new Movie(this,gDataPath + "\\looser.wav");

 }
  
   public void setup(){ 
     frameRate(10);
    _detectionResult = new DetectionResult(0,0,0);
    
    _detectionThreshold = gData.getThreshold();
    _detectionSensivity = gData.getSensivity();

    _video = null;
    
    _font = createFont("Digital-7", 40);
   
    mPrevFrame = createImage(kCAM_WIDTH,kCAM_HEIGHT,RGB);
    mCurrFrame = createImage(kCAM_WIDTH,kCAM_HEIGHT,RGB);
    mFeedback  = createImage(kCAM_WIDTH,kCAM_HEIGHT, RGB); 
    mCamCtrl   = createGraphics(kCAM_WIDTH,kCAM_HEIGHT);
   }
   
   PImage getCurrentFrame(){
     return mCurrFrame;
   }
   
   public void setInstructionMessage(String msg){
     _instructionMessage = msg;
   }
   
   public void setCamera(String cameraName){     
    if(_video != null){
      _video.stop();
    }
    
    _video = new Capture(this,kCAM_WIDTH,kCAM_HEIGHT, cameraName);
    _video.start();  
   }
 
  public void removeOrphanDetectionResult(){
    _bEnableDetection = false;
    _detectionResult.removeOrphanDetectionResult();
    _bEnableDetection = true;
  }

   public void cleanDetectionResult(){
    _bEnableDetection = false;
    _detectionResult.cleanDetectionResult();
    _bEnableDetection = true;
  }
  
  public boolean redAndGreenDotsColorsAreDefined(){
     return (_redDotPickedColor!=-1 && _greenDotPickedColor!=-1);
  }
 
  public void setDetection(boolean bStatus,int calibrationMode,boolean bInitResult){
    _bEnableDetection = bStatus;
    if(bInitResult){
      _detectionResult = new DetectionResult(0,0,0);
    }
    _calibrationMode = calibrationMode;
    _redDotPickedColor = -1;
    _greenDotPickedColor = -1;
       
    if(bStatus){
      _bPlay = false;
    }
    _detectionThreshold = gData.getThreshold();
    _detectionSensivity = gData.getSensivity();
  }

  /**
  * Set detection sensivity
  **/
  public void setDetectionSensivity(float sensivity){
    _detectionSensivity = sensivity;
  }   
   
  /**
  * Set color detection sensivity - used to calibration based on colored stickers
  **/
  public void setGoodHoldColorSensivity(float sensivity){
    _goodHoldColorDetectionSensivity = sensivity;
  }

  /**
  * Set color detection sensivity - used to calibration based on colored stickers
  **/
  public void setDeadHoldColorSensivity(float sensivity){
    _deadHoldColorDetectionSensivity = sensivity;
  }    
    
  public void play(){
    println("Start game");
    for (Dot dot : _dots) {
      println("dot #" +dot.getOrder() + " detected:" + dot.getDetected() + " type:" + dot.getType());
    }
    
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

  public void stopGame(){    
    _bEnableDetection = false;
    _bPlay = false;
    gWall.resetDotStatus();
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
    
  /**
  * Return Picked Color as int - or -1 if color is undefined
  **/  
  public int getRedPickedDotColor(){
    return _redDotPickedColor;
  }

  /**
  * Return Picked Color as int - or -1 if color is undefined
  **/  
  public int getGreenPickedDotColor(){
    return _greenDotPickedColor;
  }
  
  private boolean dotIsRed(int x,int y){
    if(_redDotPickedColor!=-1){
      int loc = x + y*_video.width; // what is the 1D pixel location              
      color current = mCurrFrame.pixels[loc]; // what is the current color
      
      float red = current >> 16 & 0xFF;
      float green = current >> 8 & 0xFF;
      float blue = current & 0xFF;
  
      float refRed = _redDotPickedColor >> 16 & 0xFF;
      float refGreen = _redDotPickedColor >> 8 & 0xFF;
      float refBlue = _redDotPickedColor & 0xFF;
  
      float diff = dist(red,green,blue,refRed,refGreen,refBlue);  
      
      return (diff < _deadHoldColorDetectionSensivity);
    }else{
      return false;
    }
  }

  private boolean dotIsGreen(int x,int y){
    if(_greenDotPickedColor!=-1){
      int loc = x + y*_video.width; // what is the 1D pixel location              
      color current = mCurrFrame.pixels[loc]; // what is the current color    
  
      float red = current >> 16 & 0xFF;
      float green = current >> 8 & 0xFF;
      float blue = current & 0xFF;
  
      float refRed = _greenDotPickedColor >> 16 & 0xFF;
      float refGreen = _greenDotPickedColor >> 8 & 0xFF;
      float regBlue = _greenDotPickedColor & 0xFF;
  
      float diff = dist(red,green,blue,refRed,refGreen,regBlue);  
      
      return (diff < _goodHoldColorDetectionSensivity);
    }else{
      return false;
    }
  }

  private boolean dotIsActive(int x,int y){
    int loc = x + y*_video.width; // what is the 1D pixel location              
    color current = mCurrFrame.pixels[loc];      // what is the current color
    color previous = mPrevFrame.pixels[loc];     // what is the previous color
  
    // compare colors (previous vs. current)
    float r1 = current >> 16 & 0xFF;
    float g1 = current >> 8 & 0xFF;
    float b1 = current & 0xFF;

    float r2 = previous >> 16 & 0xFF;
    float g2 = previous >> 8 & 0xFF;
    float b2 = previous & 0xFF;
    
    float diff = dist(r1,g1,b1,r2,g2,b2);

    return (diff > _detectionSensivity);
  }

  public void draw(){
    if(_video!=null && _video.available()){
      
      //Store previous video frame for comparison
      mPrevFrame.copy(_video,0,0,_video.width,_video.height,0,0,_video.width,_video.height); 

      _video.read();
            
      //Updated frame 
      mCurrFrame.copy(_video,0,0,_video.width,_video.height,0,0,_video.width,_video.height); 
            
      mPrevFrame.loadPixels(); 
      mCurrFrame.loadPixels();
      
      mCamCtrl.beginDraw();
      mCamCtrl.background(0);
      
      //Detection phase - always running
      //In color mode, results are cleaned every 2 sec.
      if(millis() - _timer >= 2000)
      {
       _detectionResult.cleanDetectionResult(); 
        _timer = millis();
      }

      //we divide image from cam in cells having dot size
      for(int xCell=0;xCell<kCAM_WIDTH;xCell+=kDOT_SIZE){
        for(int yCell=0;yCell<kCAM_HEIGHT;yCell+=kDOT_SIZE){
          int pixelsCount = 0;
          int redPixelsCount = 0;
          int greenPixelsCount = 0;
          for(int x=xCell;x<xCell+kDOT_SIZE;x++){
            for(int y=yCell;y<yCell+kDOT_SIZE;y++){                                             
              if(dotIsActive(x,y)) {    
                pixelsCount++;
                mFeedback.pixels[x + y*_video.width] = color(0,0,255);
              }else{
                if(dotIsGreen(x,y)){
                  mFeedback.pixels[x + y*_video.width] = color(0,255,0);
                  greenPixelsCount++;
                }else{
                  if(dotIsRed(x,y)){
                    mFeedback.pixels[x + y*_video.width] = color(255,0,0);
                    redPixelsCount++;
                  }
                }
                mFeedback.pixels[x + y*_video.width] = mPrevFrame.pixels[x + y*_video.width];   
              }
            }
          }
          if(pixelsCount > _detectionThreshold){
            //Highlight area detected - use for feedback
            mCamCtrl.fill(255);
            mCamCtrl.rect(xCell,yCell,kDOT_SIZE,kDOT_SIZE);
            if(_bEnableDetection){
              _detectionResult.setResult(xCell, yCell, pixelsCount,kPICK_MOTION_DOT);                
            }
          }else{
            // Highlight Red Hold
            if(_redDotPickedColor!=-1 && redPixelsCount > 10){
              mCamCtrl.fill(255,0,0);
              mCamCtrl.rect(xCell,yCell,kDOT_SIZE,kDOT_SIZE);              
              if(_bEnableDetection){
                _detectionResult.setResult(xCell, yCell, pixelsCount,kPICK_RED_DOT);                
              }
            }else{
              // Highlight Green Hold
              if(_greenDotPickedColor!=-1 && greenPixelsCount > 10){
                mCamCtrl.fill(0,255,0);
                mCamCtrl.rect(xCell,yCell,kDOT_SIZE,kDOT_SIZE);
                if(_bEnableDetection){
                  _detectionResult.setResult(xCell, yCell, pixelsCount,kPICK_GREEN_DOT);                
                }
              }
            }    
          }
        }
      }
      
      if(_bPlay && _pauseCount==0){
        //Game is started !!
                              
        //We only analyse detected dots 
        boolean bDoNotTouchTouched = false;
        
        boolean bTimerIsStarted = (gWall.getStartTime()>0?true:false);
        
        int dotIdx = 0;
        for (Dot dot : _dots) {
          //Only process video-dots with corresponding camera-dots
          if(dot.getDetected()){
            //The first dot trigger timer
            if(!dot.isTouched() && bTimerIsStarted || (dotIdx==0 || _calibrationMode==Calibration.kCALIBRATION_COLOR_STICKERS) && !bTimerIsStarted){
              if(!bTimerIsStarted && dot.isTouched()){
                gWall.startTimer();
                gWall.setInstructions("");
              }
              
              //test if we have motion, pixel per pixel
              int pixelsCount=0;
              for(int x=dot.getXcam();x<dot.getXcamMax();x++){
                for(int y=dot.getYcam();y<dot.getYcamMax();y++){
                   if(dotIsActive(x,y)) {    
                     pixelsCount++;
                   }                               
                }
              }
               
              if(pixelsCount > _detectionSensivity){
                println("TOUCHED - dot cam",dot.getXcam(),dot.getYcam(),"has",pixelsCount);
                // Pause detection during 1sec after each touch
                _pauseCount = 10;
                 //Start Play Game !!!
                if(dot.getType()==0){                  
                  dot.touch();
                  _goSoundfile.play();
                }else{
                  if(dot.getType()==1){                    
                    dot.touch();
                    _looserSoundfile.play();
                    bDoNotTouchTouched = true;
                    if(_nextDotOrderToTouch>0){
                      _nextDotOrderToTouch=1;
                    }
                  }else{
                    if(dot.getType()==2){
                      if(_nextDotOrderToTouch==0 || _nextDotOrderToTouch==dot.getOrder()){
                        dot.touch();
                        _touchSoundfile.play();
                        _nbUntouchedDots--;                      
                        gWall.setRemainingGreenDots(_nbUntouchedDots);
                        if(_nextDotOrderToTouch>0){
                          _nextDotOrderToTouch++;
                        }
                        println("Next hold order",_nextDotOrderToTouch);
                        println("untouched hold count",_nbUntouchedDots);
                      }
                    }
                  }
                }
              }
            }  
          }
          dotIdx++;
        }
        
        // dead hold touched
        if(bDoNotTouchTouched){
          // Restart game without reseting timer
          gWall.restartGame();
          for (Dot dot : _dots) {            
            dot.unTouch();    
          }

          _nbUntouchedDots = getNbDotsToTouch();
          gWall.setRemainingGreenDots(_nbUntouchedDots);
        }
        
        //No more dot to touch : Game WON !!
        if(_nbUntouchedDots==0){
          delay(500); //let's dot touch animation time to run          
          gWall.gameWon();
          _endSoundfile.play();
          _bPlay = false;
        }
   
      }else{
        if(_pauseCount>0){
          _pauseCount--;
        }
      }
      
      mCamCtrl.endDraw();
      mFeedback.updatePixels();
      
      if(_calibrationMode == Calibration.kCALIBRATION_COLOR_STICKERS && _bEnableDetection && !_bPlay){
        if(_redDotPickedColor == -1){
          // Pick 'red hold' color
          _instructionMessage = "COULEUR A EVITER";
        }else{
          if(_greenDotPickedColor == -1){
            // Pick 'green hold' color
            _instructionMessage = "COULEUR A TOUCHER";
          }else{
            _instructionMessage = "";
          }
        }               
      }
    
      //Display current camera image for user feedback (left pan)
      image(mFeedback,0,0,kCAM_WIDTH,kCAM_HEIGHT);      

      //Display analysed frame from camera (right pan)
      image(mCamCtrl,kCAM_WIDTH,0,kCAM_WIDTH,kCAM_HEIGHT);      

      if(_instructionMessage != ""){
        textAlign(LEFT);
        textFont(_font);
        fill(255);
        rect(0,0,textWidth(_instructionMessage)+10,50);
        fill(0);
        text(_instructionMessage,10,40);
      }
      
    }else{
      // Camera is not already chosen
      if(_video == null){
        background(255);
        textAlign(CENTER);
        textFont(_font);
        fill(0);
        text("SELECTIONNEZ UNE CAMERA",width/2,height/2);
      }
    }
  }

  /**
  * If TheWall window as focus, forward input to control window
  **/
  void keyPressed() {
    gUIControl.enterText(key,keyCode);
  }  
  
  void mousePressed(){
      
    if(_calibrationMode == Calibration.kCALIBRATION_COLOR_STICKERS){
      if(_redDotPickedColor==-1){
        // First, pick 'red dot' color
        _redDotPickedColor = get(mouseX,mouseY);
        print("red picked color " +_redDotPickedColor); 
      }else{
        if(_greenDotPickedColor==-1){
          // Pick 'green dot' color
          _greenDotPickedColor = get(mouseX,mouseY);
          print("green picked color " +_greenDotPickedColor);
        }          
      }               
    }
    
    
  }
  
  void setDots(ArrayList<Dot> dots){
    _dots = dots;
  }
 
}
