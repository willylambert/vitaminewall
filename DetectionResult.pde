public class DetectionResult{

  //store the dot coordinates with higher activity
  int _xBestActiveDot;
  int _yBestActiveDot;
  int _bestScore;
  
  //detected area
  int _minX = Integer.MAX_VALUE;
  int _minY = Integer.MAX_VALUE;
  int _maxX,_maxY;
  
  HashMap<String, int[]> _activeDots = new HashMap<String, int[]>();

  DetectionResult(int x,int y, int bestScore){
    _xBestActiveDot = x;
    _yBestActiveDot = y;
    _bestScore = bestScore;
  }
  
  /**
  * @param x : Cell X coordinate
  * @param y : Cell Y coordinate
  * @param bestScore : number of active pixels detected in cel
  * @param mode : CameraView.kPICK_MOTION_DOT | CameraView.kPICK_RED_DOT | CameraView.kPICK_GREEN_DOT 
  **/
  void setResult(int x,int y, int bestScore, int mode){
    if(bestScore > _bestScore){
      //Update best dot
      _xBestActiveDot = x;
      _yBestActiveDot = y;
      _bestScore = bestScore;
    }
    
    //Add detected camera-dot to dots collection associated to current active video-dot
    int[] dot = new int[4];
    dot[0] = x;
    dot[1] = y;
    dot[2] = bestScore;
    dot[3] = mode;
    String dotKey = x + "_" + y;
    if(!_activeDots.containsKey(dotKey)){
    _activeDots.put(dotKey,dot);
    }
  }  

  /**
  * Only keep camera-dot next to best dot
  * Identify area coordinates
  **/
  void cleanDetectionResult(){
    _activeDots.clear();
    _minX = Integer.MAX_VALUE;
    _minY = Integer.MAX_VALUE;
    _maxX = 0;
    _maxY = 0; 
    _bestScore = 0;
  }  
  
  /**
  * Only keep camera-dot next to best dot
  * Identify area coordinates
  **/
  void removeOrphanDetectionResult(){
    for (Map.Entry camDot :_activeDots.entrySet()) {
      int[] dot = (int[])camDot.getValue();
      if(dot[0] > _xBestActiveDot-2*CameraView.kDOT_SIZE && dot[0] < _xBestActiveDot+2*CameraView.kDOT_SIZE && 
         dot[1] > _yBestActiveDot-2*CameraView.kDOT_SIZE && dot[1] < _yBestActiveDot+2*CameraView.kDOT_SIZE){  
        _minX = min(dot[0],_minX);
        _maxX = max(dot[0],_maxX);
        _minY = min(dot[1],_minY);
        _maxY = max(dot[1],_maxY);
      }
    }  
  }
  
  /**
  * Color : mode : 
  **/
  public ArrayList<Dot> getDots(){
    ArrayList<Dot> dots = new ArrayList<Dot>();
    
    Dot newDot;
    
    for (Map.Entry camDot :_activeDots.entrySet()) {
      // Do we have an existing dot already initialised next to this cell ?
      int[] camDotValue = (int[])camDot.getValue();
      
      boolean bDotFound = false;
      for (Dot dot : dots) {
        if(camDotValue[0] >= dot.getXcam()-CameraView.kDOT_SIZE && camDotValue[0] <= dot.getXcamMax()+CameraView.kDOT_SIZE && 
           camDotValue[1] >= dot.getYcam()-CameraView.kDOT_SIZE && camDotValue[1] <= dot.getYcamMax()+CameraView.kDOT_SIZE){
          // extend existing dot area
          bDotFound = true;
          break;
        }
      }
      
      if(bDotFound){
        println("Extend existing dot");
      }else{
        // Colored dots are display on wall - we need to compute the right position from camera coordinates system
        float heightRatio = gWall.getHeight() / CameraView.kCAM_HEIGHT;
        float widthRatio = gWall.getWidth() / CameraView.kCAM_WIDTH;
        println("Create a new Dot ["+camDotValue[0]+"=>"+int(camDotValue[0]*widthRatio)+","+camDotValue[1]+"=>"+int(camDotValue[1]*heightRatio)+"]");
        newDot =  new Dot(int(camDotValue[0]*widthRatio),int(camDotValue[1]*heightRatio),camDotValue[3],null,null,dots.size(),false);
        newDot.setCamCoordinates(camDotValue[0],camDotValue[1],camDotValue[0]+CameraView.kDOT_SIZE,camDotValue[1]+CameraView.kDOT_SIZE);
        newDot.setDetected(true);
        newDot.setOrder(dots.size());
        dots.add(newDot);
      }
    }
    
    return dots;
  }
  
  int getMinX(){
    return _minX;
  }

  int getMaxX(){
    return _maxX+CameraView.kDOT_SIZE;
  }

  int getMinY(){
    return _minY;
  }

  int getMaxY(){
    return _maxY+CameraView.kDOT_SIZE;
  }
  
  int getX(){
    return _xBestActiveDot;
  }

  int getY(){
    return _yBestActiveDot;
  }  
  
  int getBestScore(){
    return _bestScore;
  }
}
