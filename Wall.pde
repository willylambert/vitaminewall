/**
* A Wall object : contains dots, screen dimension, and wall name
**/

class Wall{

  String _name;
  ArrayList<Dot> _dots = new ArrayList<Dot>();
  int _screenWidth;
  int _screenHeight;

  void setName(String name){
    _name = name;
  }
  
  String getName(){
    return _name;
  }
  
  void addDot(Dot dot){
    _dots.add(dot);
  }
  
  ArrayList<Dot> getDots(){
    return _dots;
  }  
  
  void setDots(ArrayList<Dot> dots){
    _dots = dots;
  }  
  
  void setScreen(int w,int h){
    _screenWidth = w;
    _screenHeight = h;
  }
  
  int getWidth(){
    return _screenWidth;
  }

  int getHeight(){
    return _screenHeight;
  }

}