class Data{

  JSONObject json;
  ArrayList<Wall> _walls = new ArrayList<Wall>();
  
  Wall _currentWall;
  
  Data(){
    loadData();
  }
  
  void loadData(){
    String filename = "data.json";
    
    if (dataFile(filename).exists())
    {
      json = loadJSONObject(filename);
      println("load from data.json");
      
      JSONArray walls = json.getJSONArray("walls");
      
      _walls.clear();
      
      for(int i=0;i<walls.size();i++){
        Wall wall = new Wall();
        JSONObject wallItem = walls.getJSONObject(i);
        String name = wallItem.getString("name");
        JSONArray dots = wallItem.getJSONArray("dots");
        wall.setName(name);
        for(int d=0;d<dots.size();d++){
          JSONObject dotItem = dots.getJSONObject(d);
          int x = dotItem.getInt("x");
          int y = dotItem.getInt("y");
          int type = dotItem.getInt("type");
          int order = dotItem.getInt("order");
          Dot dot = new Dot(x,y,type,null,null,order);
          wall.addDot(dot);
        }
        _walls.add(wall);
      }
    }else{
      println(filename + " not found");
    }
  }
  
  void setCurrentWall(int index){
     _currentWall = _walls.get(index); 
  }
  
  ArrayList<Wall> getWalls(){
    return _walls;
  }
  
  /**
  * Start Creation of a new wall
  **/
  void newWall(){
    _currentWall = new Wall();
  }
  
  Wall getCurrentWall(){
    return _currentWall;
  }
  
  /**
  * Save current dots to a new wall
  **/
  void saveWall(int index){
     println("saveWall");
     String filename = "data.json";
     json = new JSONObject();

     if (dataFile(filename).exists()){
        json = loadJSONObject(filename);
        println("load from data.json");
     }
     
     JSONObject wall = new JSONObject();
     wall.setString("name",_currentWall.getName());
     wall.setInt("width",_currentWall.getWidth());
     wall.setInt("height",_currentWall.getHeight());
     
     JSONArray jsonDots = new JSONArray();
     
     ArrayList<Dot> dots = _currentWall.getDots();
          
     for (int i=0;i<dots.size();i++) {
       jsonDots.setJSONObject(i,dots.get(i).getJSON());
     }
     
     println("set dots");
     wall.setJSONArray("dots",jsonDots);
     
     JSONArray jsonWall;

     jsonWall = json.getJSONArray("walls");
     
     if(jsonWall==null){
      jsonWall = new JSONArray();
     }
     
     println("set json wall",jsonWall);
     jsonWall.setJSONObject(index,wall);
     println("save json");
     
     json.setJSONArray("walls",jsonWall); 
     
     saveJSONObject(json,dataPath(filename));    
     
  }
    
  void setDots(ArrayList<Dot> dots){
    _currentWall.setDots(dots);
  }
}