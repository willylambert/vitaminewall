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

class Dot{
  
  int _camX,_camY; // => coordinates from the Camera POV
  
  int _x, _y; // => coordinates from the Wall POV
  
  int _dotType; // => type : 0 => Not defined, 1 => Do Not Touch, 2 => To be Touched
  
  boolean _touched; // => true/false : touched
  
  Dot(int x,int y,int camX,int camY, int dotType){
    _x = x;
    _y = y;
    _camX = camX;
    _camY = camY;
    _dotType = dotType;
  }
  
  void display(){
    if(_dotType==1){
      fill(255,0,0);
    }else{
      fill(0,255,0);
    }
    print("dot at ",_x,",",_y);
    rect(_x, _y, 20, 20, 7);
  }

}