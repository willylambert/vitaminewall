  public class DetectionResult{

  // store the dot coordinates with higher activity
  int _xActiveDot;
  int _yActiveDot;
  int _bestScore;

  DetectionResult(int x,int y, int bestScore){
    _xActiveDot = x;
    _yActiveDot = y;
    _bestScore = bestScore;
  }
  
  void setResult(int x,int y, int bestScore){
    _xActiveDot = x;
    _yActiveDot = y;
    _bestScore = bestScore;
  }  
  
  int getX(){
    return _xActiveDot;
  }

  int getY(){
    return _yActiveDot;
  }  
  
  int getBestScore(){
    return _bestScore;
  }
}