  public class Calibration{
   
  ArrayList<Dot> _dots = new ArrayList<Dot>();
  
  CameraView _camView;
  TheWall _theWall;
  
  static final int _hueRange = 360; 

  // dots size in pixels
  static final int kDOT_SIZE = 80;
  
  static final int kCALIBRATION_VP = 1;
  static final int kCALIBRATION_COLOR_STICKERS = 2;
  
  // Calibration could be done by displaying dots on wall with VP (kCALIBRATION_VP)
  // or by colored stickers : green = hold to touch / red = hold to avoid (kCALIBRATION_COLOR_STICKERS)
  int _calibrationMode;
  
  Calibration(CameraView camView,TheWall theWall, int calibrationMode){
     _camView = camView;
     _theWall = theWall;
     _calibrationMode = calibrationMode;
  }

   /**
  * Association wall calibration image to dots coordinates detected by camera view
  **/
  public int calibrate(){
    int ret = 0;        

    // Dots came from interactive editor
    if(_calibrationMode == kCALIBRATION_VP){
      _dots = gData.getCurrentWall().getDots();
      ret = calibrateByMotionDetection();
    }else{
      if(_calibrationMode == kCALIBRATION_COLOR_STICKERS){
        // Use physical colored dots sticked on wall
        // Calibration process : 
        // 1 : pick 'dead hold' color
        // 2 : pick 'good hold' color
        // 3 : detect area with either 'dead' or 'good' dots              

        // Init cam for a new detection run
        _camView.setDetection(true,_calibrationMode,true);
      }
    }
    
    return ret;
  }
  
  public void saveColorCalibrationResult(){
   
      // Color are picked, stop detection and read result
      _camView.setDetection(false,_calibrationMode,false);
      
      // Get Green / Red Dots
      DetectionResult detectionResult = _camView.getDetectionResult();
      
      print("saveColorCalibrationResult getDots");
      _dots = detectionResult.getDots();
      
      // Wait end
      println("Detect colored dots : " + _dots.size());
      
      // ask the wall to display the result of calibration
      println("calibration done");
      _theWall.showCalibrationResult(_dots);
      _camView.setDots(_dots);        

  }
 
  /**
  * Association wall calibration image to dots coordinates detected by camera view
  **/
  public int calibrateByMotionDetection(){
    println("Calibrate by motion detection for " + _dots.size() + " dots");
    int ret = 0;
    
    //We need to show dot one by one during detection
    for (Dot dot : _dots) {
       dot.hide();
    }
              
    //Init cam for a new detection run
    _camView.setDetection(true,_calibrationMode,true);

    int dotIdx = 0;
    for (Dot dot : _dots) {
      dotIdx++;
      delay(500);

      println("start detection for dot", dot.getX(),dot.getY());
      _camView.cleanDetectionResult();
      
      dot.show();
      //Start blinking dot
      dot.setBlink(true);          
      
      //get area which get the most activity during detection run
      DetectionResult detectionResult = _camView.getDetectionResult();
      
      int startDt = millis();
      while(detectionResult.getBestScore() < 200 && millis()-startDt < 750){               
        detectionResult = _camView.getDetectionResult();
      }
      
      println("Best Score is ",detectionResult.getBestScore()," for dot[",detectionResult.getX(),",",detectionResult.getY(),"]");
      
      if(detectionResult.getBestScore() >= 200){
        println("Dot "+dotIdx+" detected ! Best is ["+detectionResult.getX()+","+detectionResult.getY()+",s="+detectionResult.getBestScore()+"]");                        
        //Only keep contiguous dot next to best detected dot
        _camView.removeOrphanDetectionResult();
        println("Dot "+dotIdx+" detected ! Area is ["+detectionResult.getMinX()+","+detectionResult.getMinY()+"] ["+detectionResult.getMaxX()+","+detectionResult.getMaxY()+"]");

        // (x,y) => best camera-dot, last parameter => all linked camera-dots
        dot.setCamCoordinates(detectionResult.getMinX(),detectionResult.getMinY(),detectionResult.getMaxX(),detectionResult.getMaxY());
        dot.setDetected(true);        
      }
      dot.hide();      
    }
 
    int i=1;
    for (Dot dot : _dots) {
      if(dot.getDetected()){ 
        dot.setBlink(false);
        dot.show();
        if(dot.getType()==2){
          dot.setOrder(i++);
        }
      }      
    }        
        
    // ask the wall to display the result of calibration
    println("calibration done");
    _theWall.showCalibrationResult(_dots);
    _camView.setDots(_dots);
                            
    return ret;
  }
  
}
