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


class ReadyToGo{
  PImage _readyToGoImage;
  PShape _shapePill;

  int _welcomePillX = 0;
  int _welcomePillAngle = 0;
  
  ArrayList<Dot> _dots = new ArrayList<Dot>();
  
  ReadyToGo(PGraphics g){
    _readyToGoImage = loadImage(dataPath("welcome.png"));
    _readyToGoImage.resize(g.width,g.height);
    _shapePill = loadShape(dataPath("pill.svg"));        
  }
  
  void display(PGraphics g, int frmCount){
    g.image(_readyToGoImage,0,0);
    
    //each 24 frames
    if (frmCount % 24 == 0) {
      Dot dot = new Dot(int(random(0,g.width)),int(random(g.height*0.5,g.height*0.7)),int(random(1,3)),null,null,0);
      _dots.add(dot);
      
      Dot dotTouch = _dots.get(int(random(_dots.size())));
      dotTouch.touch();
      
      if(_dots.size()>5){
        _dots.remove(int(random(_dots.size())));
      }
    }

    for (Dot dot : _dots) {
      dot.display(g, true, true);
    }
  }
  
}