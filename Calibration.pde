  public class Calibration{
   
  ArrayList<Dot> _dots = new ArrayList<Dot>();
  
  CameraView _camView;
  TheWall _theWall;
  
  static final int _hueRange = 360; 

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
    println("calibrate");
    int ret = 0;

    _dots = gData.getCurrentWall().getDots();
    
    //We need to show dot one by one during detection
    for (Dot dot : _dots) {
       dot.hide();
    }
    
    //Start blinking one by one to get cameras coordinates for each one        
    delay(1000);

    for (Dot dot : _dots) {
      delay(500);

      //Init cam for a new detection run
      _camView.setDetection(true);

      println("start detection for dot", dot.getX(),dot.getY());
      dot.show();
      dot.setBlink(true);
      
      //get area which get the most activity during detection run
      //wait for detection result
      DetectionResult detectionResult =_camView.getDetectionResult();
      
      int startDt = millis();
      while(detectionResult.getBestScore() < 200 && millis()-startDt < 750){               
        detectionResult = _camView.getDetectionResult();
      }
      
      println("Best Score is ",detectionResult.getBestScore()," for dot[",detectionResult.getX(),",",detectionResult.getY(),"]");
      
      if(detectionResult.getBestScore() >= 200){
        println("Dot detected !",detectionResult.getX(),detectionResult.getY(),detectionResult.getBestScore());
        dot.setCamCoordinates(detectionResult.getX(),detectionResult.getY());
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