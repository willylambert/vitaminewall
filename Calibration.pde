public class Calibration{
   
  ArrayList<Dot> _dots = new ArrayList<Dot>();
  
  CameraView _camView;
  TheWall _theWall;
  
  static final int _hueRange = 360; 
  
  // How different must a pixel be to be a "motion" pixel
  static final float kTHRESHOLD = 35;
  static final float kSENSIVITY = 30; //number of pixels changed to light a dot
  
  // 640 x 480 resolution is enough fr camera to do motion detection
  static final int kCAM_WIDTH = 640;
  static final int kCAM_HEIGHT = 480;
  
  // dots size in pixels
  static final int kDOT_SIZE = 80;
  
  Calibration(CameraView camView,TheWall theWall){
     _camView = camView;
     _theWall = theWall;
  }
 
  /**
  * Association wall calibration image to dots coordinates detected by camera view
  **/
  public int calibrate(){
    int ret = 0;

    //Step 1 : analyse calibration image to get wall aeras with a 20x20 res
    _theWall.showCalibrationImage();
    PImage wallImg = _theWall.getWallImg();

    // read it by 20x20 pixels area
    //do we detect a "touch" or a "do not touch" area ?
    for(int xDot=0;xDot<wallImg.width-kDOT_SIZE;xDot+=kDOT_SIZE){
      for(int yDot=0;yDot<wallImg.height-kDOT_SIZE;yDot+=kDOT_SIZE){
        //We are on a dot - analyse it pixel per pixel
        int redCount = 0;
        int greenCount = 0;
        for(int x=xDot;x<xDot+kDOT_SIZE;x++){          
          for(int y=yDot;y<yDot+kDOT_SIZE;y++){
            int loc = x + y*wallImg.width;            // what is the 1D pixel location
            color current = wallImg.pixels[loc];      // what is the current color
            if(red(current) > 200 && green(current) < 100 && blue(current) < 100){
              redCount++;
            }else{
              if(green(current) > 200 && red(current) < 100 && blue(current) < 100){
                greenCount++;
              }
            }
          }
        }
        if(redCount > kDOT_SIZE*kDOT_SIZE/2){
          println("Red dot at ["+xDot+","+yDot+"]");
          _dots.add(new Dot(xDot,yDot,1));
        }else{
          if(greenCount > kDOT_SIZE*kDOT_SIZE/2){
            println("Green dot at ["+xDot+","+yDot+"]");
            _dots.add(new Dot(xDot,yDot,2));
          }
        }
      }
    }
    
    // ask the wall to display the result of calibration step 1
    _theWall.showCalibrationResult(_dots);
 
    //Step 2 : we have a list of dots from image POV
    
    //We need to show dot one by one during detection
    for (Dot dot : _dots) {
       dot.hide();
    }
    
    //Start blinking one by one to get cameras coordinates for each one        
    //delay(2000);

    for (Dot dot : _dots) {
      delay(1000);

      //Init cam for a new detection run
      _camView.setDetection(true);

      println("start detection for dot", dot.getX(),dot.getY());
      dot.show();
      dot.setBlink(true);
      
      //get area which get the most activity during detection run
      //wait for detection result
      
      DetectionResult detectionResult =_camView.getDetectionResult();
      
      int startDt = millis();
      while(detectionResult.getBestScore() < 200 && millis()-startDt < 1000){               
        detectionResult = _camView.getDetectionResult();
      }
      
      if(detectionResult.getBestScore() >= 200){
        println("Dot detected !",detectionResult.getX(),detectionResult.getY(),detectionResult.getBestScore());
        dot.setCamCoordinates(detectionResult.getX(),detectionResult.getY());
        dot.setDetected(true);
      }
      dot.hide();      
    }
 
    for (Dot dot : _dots) {
      if(dot.getDetected()){ 
        dot.setBlink(false);
        dot.show();        
      }
    }        
        
    // ask the wall to display the result of calibration
    _theWall.showCalibrationResult(_dots);
    _camView.setDots(_dots);
                            
    return ret;
  }
  
}