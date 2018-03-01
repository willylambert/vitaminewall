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
              
    //Init cam for a new detection run
    _camView.setDetection(true);

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