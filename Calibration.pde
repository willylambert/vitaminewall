public class Calibration{
   
  ArrayList<Dot> _dots = new ArrayList<Dot>();
  
  CameraView _camView;
  TheWall _theWall;
  
  static final int _hueRange = 360; 
  
  // How different must a pixel be to be a "motion" pixel
  static final float kTHRESHOLD = 35;
  static final float kSENSIVITY = 30; //number of pixels changed to light a dot
  
  // 640 x 480 resolution is enough for camera to do motion detection
  static final int kCAM_WIDTH = 640;
  static final int kCAM_HEIGHT = 480;
  
  // dots size in pixels
  static final int kDOT_SIZE = 20;
  
  Calibration(CameraView camView,TheWall theWall){
     _camView = camView;
     _theWall = theWall;
  }
 
  /**
  **/
  public int calibrate(){
    int ret = 0;

    // First, analyse calibration image to get wall aeras with a 20x20 res
    PImage wallImg = _theWall.getWallImg();

    // get current camera frame
    // _camView.getCurrentFrame();  

    // read it by 20x20 pixels area
    //do we detect a "touch" or a "not touch" area ?
    for(int xDot=0;xDot<kCAM_WIDTH;xDot+=kDOT_SIZE){
      for(int yDot=0;yDot<kCAM_HEIGHT;yDot+=kDOT_SIZE){
        //We are on a dot - analyse it pixel per pixel
        int redCount = 0;
        int greenCount = 0;
        for(int x=xDot;x<xDot+kDOT_SIZE;x++){          
          for(int y=yDot;y<yDot+kDOT_SIZE;y++){
            int loc = x + y*wallImg.width;            // what is the 1D pixel location
            color current = wallImg.pixels[loc];      // what is the current color
            if(red(current) > 200 && green(current) < 100 && blue(current) < 100){
              redCount++;
            }else{
              if(green(current) > 200 && red(current) < 100 && blue(current) < 100){
                greenCount++;
              }
            }
          }
        }
        if(redCount > kDOT_SIZE*kDOT_SIZE/2){
          println("Red dot at ["+xDot+","+yDot+"]");
          _dots.add(new Dot(xDot,yDot,xDot,yDot,1));
        }else{
          if(greenCount > kDOT_SIZE*kDOT_SIZE/2){
            println("Green dot at ["+xDot+","+yDot+"]");
            _dots.add(new Dot(xDot,yDot,xDot,yDot,2));
          }
        }
      }
    }
    
    // ask the wall to display the result of calibration
    _theWall.showCalibrationResult(_dots);
              
    return ret;
  }
  
}