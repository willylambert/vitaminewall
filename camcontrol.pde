import processing.video.*;
import processing.sound.*;

public class ControlDisplay extends PApplet {

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

    mVideo.start();  
   
    mPrevFrame = createImage(mVideo.width,mVideo.height,RGB);
    mCurrFrame = createImage(mVideo.width,mVideo.height,RGB);  
    mFeedback = createImage(mVideo.width,mVideo.height, RGB); 
    mCamCtrl = createGraphics(mVideo.width,mVideo.height);

   }
 
  public void setDetection(boolean bStatus){
    bEnableDetection = bStatus;
    if(!bStatus){
      mLastDetectionTime = millis();
    }
  }
   
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
}