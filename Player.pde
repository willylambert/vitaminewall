class Climber implements Comparable{
  int score;
  String name;
  int rank;

  Climber(){
    name = "--";
    score = MAX_INT;
    rank = -1;
  }

  int compareTo(Object o){
    Climber p = (Climber)o;
    return (score-p.score>0?1:0);
  }  
}