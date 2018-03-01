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
  
  void setResult(int x,int y, int bestScore){
    if(bestScore > _bestScore){
      //Update best dot
      _xBestActiveDot = x;
      _yBestActiveDot = y;
      _bestScore = bestScore;
    }
    
    //Add detected camera-dot to dots collection associated to current active video-dot
    int[] dot = new int[3];
    dot[0] = x;
    dot[1] = y;
    dot[2] = bestScore;
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