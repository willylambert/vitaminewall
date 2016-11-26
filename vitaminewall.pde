import controlP5.*;

// How different must a pixel be to be a "motion" pixel
float kTHRESHOLD = 60;
float kSENSIVITY = 50; //number of pixels changed to light a dot

// 640 x 480 resolution is enough for camera to do motion detection
int kCAM_WIDTH = 640;
int kCAM_HEIGHT = 480;

// dots size in pixels
int kDOT_SIZE = 50;

// [0,1] => screen X, Y
// [2,3] => camera cell X, Y
// [4] => touched - true/false
int[][] gTblDots = new int[100][5];
int gNbDots = 0;
int gCurrentDot = 0;

//Screen buffers
PGraphics gWall;

//Font use
PFont gFont;

ControlP5 cp5;
controlP5.Button btnGo;

boolean bPlay = false;
boolean bChooseDots = false;
boolean bRecordDot = false;
boolean bEnableDetection = true;
boolean bDisplayScore = false;

//Timer
int gStartTime;
Textlabel mTimerLabel; 

//Debug Log a climbwall bottom
Textlabel mLog;

//Results
Textlabel mGameWonLabel;
int gLastScore = 0;

//UI Label
Textlabel mChooseDotsLabel;
Textfield mClimberName;

//Store Hall Of Fame
Climber[] gHallOfFame = new Climber[10]; 

ControlDisplay gCamView;

void settings(){
 //Go FullScreen on second display
  fullScreen(2);
}

void setup(){ 
  
  //Center rectangle when drawing
  rectMode(CENTER);
  
  gWall = createGraphics(displayWidth,displayHeight);
  gFont = createFont("Digital-7",50);
  
  //Launch control window on main screen
  String[] args = {"--location=0,0", "ClimbWall"};

  cp5 = new ControlP5(this);

  mTimerLabel = new Textlabel(cp5,"--",10,10);
  mTimerLabel.setFont(gFont);
     
  mGameWonLabel = new Textlabel(cp5,"",10,displayHeight/4);   
  mGameWonLabel.setFont(gFont);

  mLog = new Textlabel(cp5,"",10,displayHeight-20);   
  mLog.setFont(createFont("Digital-7",20));

  // Start Game button
  btnGo = cp5.addButton("Go").setPosition(displayWidth-110,10).setSize(100,60).setFont(gFont);
  
  gCamView = new ControlDisplay();
  PApplet.runSketch(args, gCamView);   
  background(0);
  noStroke();
  
  for(int i=0;i<10;i++){
    gHallOfFame[i] = new Climber();
  }
  
  bChooseDots = true;
}

void draw() {
  
  /**
  * Select dots
  **/
  if(bChooseDots){
    if(gNbDots==0){
      mChooseDotsLabel = new Textlabel(cp5,"",10,10); 
      mChooseDotsLabel.setFont(gFont);

      mChooseDotsLabel.setValue("Placez les zones sur le mur ");
      mChooseDotsLabel.draw(this);
      btnGo.hide();
    }else{
      btnGo.show();
    }
  }
  
  /**
  * Game is started !
  **/
  if(bPlay){
    btnGo.hide();
    
    gWall.beginDraw();
    gWall.background(0);

    //Handle drawing of first dot
    if(gCurrentDot == 0){
      gWall.rect(gTblDots[0][0],gTblDots[0][1],kDOT_SIZE,kDOT_SIZE);
    }else{    
      //At least one dot is touched
      if(gCurrentDot < gNbDots){               
        for(int i=0;i<=gCurrentDot;i++){
          if(gTblDots[i][4]==0){
            gWall.fill(255,255,255);
          }else{
            gWall.fill(0,255,0);  
          }
          gWall.ellipse(gTblDots[i][0],gTblDots[i][1],kDOT_SIZE,kDOT_SIZE);
        }
      }
    }
    
    gWall.endDraw();
    image(gWall,0,0,displayWidth,displayHeight); 

    mLog.draw(this);

    /**
    * Draw timer after first touch
    **/
    if(gCurrentDot>0 && gCurrentDot<gNbDots){
      mTimerLabel.setValue(nf((millis()-gStartTime)/1000.,3,1));
      mTimerLabel.draw(this);
    }else{
      /**
      * We have a winner !!
      **/
      if(gCurrentDot>=gNbDots && gLastScore==0){
        gLastScore = millis()-gStartTime;
        println("You Win !!");
        background(0);
        mGameWonLabel.setValue(" Pas mal ...  " + nf((gLastScore)/1000.,1,1) + " secondes !!");
        mGameWonLabel.draw(this);
        bPlay = false;
       
        cp5.addTextfield("Climber")
           .setPosition(displayWidth/4,displayHeight/2-30)
           .setSize(600,60)
           .setFont(gFont)
           .setFocus(true);      
      }
    }
  }else{
    /**
    * Hall Of Fame
    **/
    if(bDisplayScore){
      textFont(gFont,60);
      background(0);
      fill(255); 
      for(int i=0;i<10;i++){
        if(gHallOfFame[i].score!=MAX_INT){
          String score =  (i+1) + " -  " +  nf((gHallOfFame[i].score)/1000.,1,1) + " s - " + gHallOfFame[i].name;
          text(score,50,100+i*60);
        }        
      }
    }
  }
}

public void Climber(String climberName) {
  //new score
  println("We have a new winner !",climberName);
  int climberRank = -1;
  //Handle first entry in hall of fame
  if(gHallOfFame[0].score==0){
    climberRank = 0;
  }else{
    for(int i=0;i<10;i++){
      if( gLastScore < gHallOfFame[i].score ){
        //Yes ! new entry into hall of fame !
        climberRank = i;
        break;
      }
    }
}
  if(climberRank>-1){
    //Insert player and shift looser
    for(int i=9;i>climberRank;i--){
      gHallOfFame[i] = gHallOfFame[i-1]; 
    }
    gHallOfFame[climberRank] = new Climber();
    gHallOfFame[climberRank].score = gLastScore;
    gHallOfFame[climberRank].name = climberName;
  }
  cp5.get("Climber").hide();  
  bDisplayScore = true;
  btnGo.show();
}


 void Go(int value){
   println("Start Playing");
   gCurrentDot = 0;
   for(int i=0;i<gNbDots;i++){
     gTblDots[i][4] = 0;
   }     
   background(0);
   bPlay = true;
   bChooseDots = false;
   bDisplayScore = false;

   //will be enable again after 500 ms - see draw method of camControl class
   gCamView.setDetection(false);
   
   gCurrentDot = 0;
   gLastScore = 0;
 }

void mouseClicked() {
  //Store dots
  println("new dot at ",mouseX," ",mouseY);
  gTblDots[gNbDots][0] = mouseX;
  gTblDots[gNbDots][1] = mouseY;  
  bRecordDot = true;
  rect(mouseX,mouseY,kDOT_SIZE,kDOT_SIZE);  
}