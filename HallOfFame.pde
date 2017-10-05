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

class HallOfFame{
  ArrayList<ArrayList<Player>> _levels = new ArrayList<ArrayList<Player>>();  
  
  PFont _font;
  
  HallOfFame(){
    //Init hall of Fame with 3 levels    
    _levels.add(new ArrayList<Player>());
    _levels.add(new ArrayList<Player>());
    _levels.add(new ArrayList<Player>());

     //default font
    _font = createFont("Digital-7", 15);
  }
  
  void add(int level,int time,String playerName){    
    //new score
    println("We have a new winner ! for level " + level,playerName);
    int i = 0;
    boolean betterScoreFound = false;
    for(Player player : _levels.get(i-1)){        
      if( time < player.getScore() ){
        //Yes ! new entry into hall of fame !
        _levels.get(level).add(i,new Player(time,playerName));
        betterScoreFound = true;
        break;
      }
      i++;
    }
    
    //insert at the end
    if(!betterScoreFound){
      _levels.get(level-1).add(new Player(time,playerName));
    }
  }
  
  void display(PGraphics g){
    g.background(0);
    g.fill(255);
    for(int i=0;i<_levels.size();i++){
      int j = 0;
      g.text("Niveau " + (i+1),i*g.width/3,(j+1)*75);
      for(Player player : _levels.get(i)){
        //display player result
        g.text(player.toString(),i*g.width/3,(j+2)*75);
        j++;
      }
    }
  }
  
}