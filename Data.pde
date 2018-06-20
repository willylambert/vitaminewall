  class Data{

  String _filename = "data.json";
  JSONObject _json;
  ArrayList<Wall> _walls = new ArrayList<Wall>();
      
  //Default values
  static final float kTHRESHOLD = 70; //Number of pixels changed to light a dot
  static final float kSENSIVITY = 50; //How different must a pixel be to be detected as a "motion" pixel
  
  static final int kCALIBRATION_VP = 1;
  static final int kCALIBRATION_COLOR_STICKERS = 2;
  
  float _sensivity = kTHRESHOLD;
  float _threshold = kSENSIVITY;
  
  Wall _currentWall;
  
  Data(){
    loadData();
  }
  
  void loadData(){
    String filename = "data.json";
    
    if (dataFile(filename).exists())
    {
      _json = loadJSONObject(filename);

      if(!_json.isNull("sensivity") && !_json.isNull("threshold")) {
        _sensivity = _json.getFloat("sensivity");
        _threshold = _json.getFloat("threshold");
      }
      
      JSONArray walls = _json.getJSONArray("walls");
      
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
          Dot dot = new Dot(x,y,type,null,null,order,false);
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
  * Save Detection level to disk
  **/
  void saveDetectionLevels(){
    _json.setFloat("sensivity",_sensivity);
    _json.setFloat("threshold",_threshold);
    saveJSONObject(_json,dataPath(_filename));
  }
  
  /**
  * Save current dots to a new wall
  **/
  void saveWall(int index){
     
     _json = new JSONObject();

     if (dataFile(_filename).exists()){
        _json = loadJSONObject(_filename);
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
     
     wall.setJSONArray("dots",jsonDots);
     
     JSONArray jsonWall;

     jsonWall = _json.getJSONArray("walls");
     
     if(jsonWall==null){
      jsonWall = new JSONArray();
     }
     
     jsonWall.setJSONObject(index,wall);
     
     _json.setJSONArray("walls",jsonWall); 
     
     saveJSONObject(_json,dataPath(_filename));    
     
  }
  
  float getSensivity(){
    return _sensivity;
  }
  
  void setSensivity(float sensivity){
    _sensivity = sensivity;
  }
  
  float getThreshold(){
    return _threshold;
  }
  
  void setThreshold(float threshold){
    _threshold = threshold;
  }
    
  void setDots(ArrayList<Dot> dots){
    _currentWall.setDots(dots);
  }
}
