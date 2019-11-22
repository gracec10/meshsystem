import processing.serial.*;


int sliderVal;


int headLength;
int headWidth;
int headSpotX;
int headSpotY;

int neckWidth;
int neckHeight;
int neckTopX;
int neckTopY;
int neckBotLeftX;
int neckBotLeftY;
int neckBotRightX;
int neckBotRightY;

int torsoTopWidth;
int torsoBotWidth;
int torsoHeight;
int shoulderLeftX;
int shoulderLeftY;
int shoulderRightX;
int shoulderRightY;
int hipLeftX;
int hipLeftY;
int hipRightX;
int hipRightY;

int leftThighTopRightX;
int leftThighTopRightY;
int leftThighBotLeftX;
int leftThighBotLeftY;

int rightThighTopLeftX;
int rightThighTopLeftY;
int rightThighBotRightX;
int rightThighBotRightY;

int rightCalfTopRightX;
int rightCalfTopRightY;
int rightCalfBotLeftX;
int rightCalfBotLeftY;
  
int leftCalfTopLeftX;
int leftCalfTopLeftY;
int leftCalfBotRightX;
int leftCalfBotRightY;

int leftFootTopX;
int leftFootTopY;
int leftFootBotRightX;
int leftFootBotRightY;
int leftFootBotLeftX;
int leftFootBotLeftY;
  
int rightFootTopX;
int rightFootTopY;
int rightFootBotLeftX;
int rightFootBotLeftY;
int rightFootBotRightX;
int rightFootBotRightY;

int leftUpperArmTopRightX;
int leftUpperArmTopRightY;
int leftUpperArmBotLeftX;
int leftUpperArmBotLeftY;

int rightUpperArmTopLeftX;
int rightUpperArmTopLeftY;
int rightUpperArmBotRightX;
int rightUpperArmBotRightY;

int leftLowerArmTopLeftX;
int leftLowerArmTopLeftY;
int leftLowerArmBotRightX;
int leftLowerArmBotRightY;

int rightLowerArmTopRightX;
int rightLowerArmTopRightY;
int rightLowerArmBotLeftX;
int rightLowerArmBotLeftY;

float [] rotate = new float[13]; //holder for rotation values of each body part
int [] pivots = new int[26]; //pivot points for each body part
int [] translate = new int[26]; // translation state for each body part
int rotatingFlag = 99; //0-13 to indicate what body part is being rotated; 99 for none

Serial port;

float spinAngle;
int spinPart=int(random(0,12));
int spinTimer;
float speed=4;
int direction=0;
int readNewSerial=1;
int wind;

int backColor;
int snowColor;

int []snowLocations = new int[46];
color bodyColor = color(100,100,50, 85);

int colorUp=1;

//transformation hierarchies:
//                                        Torso
// Neck       leftUpArm          rightUpArm       leftThigh           rightThigh
// Head        leftLowArm        rightLowArm      leftCalf            rightCalf
//                                                leftFoot            rightFoot


void setup(){
  port = new Serial(this, Serial.list()[0], 115200);
  //size(1000, 750);
  fullScreen();
  background(0);
  fill(255);
  setVars();
  textAlign(CENTER);
  textSize(75);
  
  
  //initialize translation list
  for (int i=0; i< 26; i++){
    translate[i]=0;
  }
}

void draw(){
  noStroke();
  background(backColor, 20, 255-backColor);
  fill(snowColor);
  updateSnow();
  drawSnow();
  fill(255);
  /*while (myPort.available() > 0) {
    String data = myPort.readString();   
    if (data != null) {}
    */
   fill(bodyColor);
   drawHead();
   drawNeck();
   drawTorso();
   drawThighs();
   drawCalves();
   drawFeet();
   drawUpperArms();
   drawLowerArms();
   stroke(200);
   fill(0);
   //fill(color(green(bodyColor),blue(bodyColor),red(bodyColor),90));
   text("Welcome to the black box, and please enjoy your visit.",width/2,7*height/8);
   
   rotatingFlag=99;
   if(port.available()>0){
     if(readNewSerial==1){
       parseSerialLine();
       readNewSerial=0;
     }
     else{
       spin();
       delay(10);
     }
   }
   if(colorUp>0){
     bodyColor=color(red(bodyColor)+5,green(bodyColor)+5,blue(bodyColor)+5, 85);
     if(red(bodyColor)>=255||green(bodyColor)==255||blue(bodyColor)==255){colorUp=0;}
   }
   else{   
     bodyColor=color(red(bodyColor)-5,green(bodyColor-5),blue(bodyColor-5),85);
     if(red(bodyColor)<=0||green(bodyColor)==0||blue(bodyColor)==0){colorUp=1;}
   }
}

/*
******* Init Params
******* Init Params
*/
void setVars(){
  
  for(int i=0; i< 46; i+=2){
    snowLocations[i]=int(random(width));
    snowLocations[i+1]=int(random(-height,0));
  }
  
  headLength = height/10;
  headWidth = headLength/2;
  headSpotX = width/2;
  headSpotY= headLength/2;
  
  neckHeight= headLength/2;
  neckWidth = headWidth;
  neckTopX = headSpotX;
  neckTopY = headSpotY + headLength/2;
  neckBotLeftX = headSpotX - headWidth/2;
  neckBotLeftY = headSpotY + headLength;
  neckBotRightX = headSpotX + headWidth/2;
  neckBotRightY = neckBotLeftY;
  
  torsoTopWidth = headWidth * 3;
  torsoBotWidth = int(headWidth * 1.5);
  torsoHeight = int(headLength * 2);
  shoulderLeftX = neckBotLeftX - torsoTopWidth/2;
  shoulderLeftY = neckBotLeftY;
  shoulderRightX = neckBotRightX + torsoTopWidth/2;
  shoulderRightY = neckBotRightY;
  hipLeftX = shoulderLeftX+ torsoBotWidth/2;
  hipLeftY = shoulderLeftY + torsoHeight;
  hipRightX = shoulderRightX - torsoBotWidth/2;
  hipRightY = shoulderRightY + torsoHeight;
  
  leftThighTopRightX = hipLeftX;
  leftThighTopRightY = hipLeftY;
  leftThighBotLeftX = leftThighTopRightX-(headWidth/2);
  leftThighBotLeftY = leftThighTopRightY + (headLength*2);
  
  rightThighTopLeftX = hipRightX;
  rightThighTopLeftY = hipRightY;
  rightThighBotRightX = rightThighTopLeftX+(headWidth/2);
  rightThighBotRightY = rightThighTopLeftY + (headLength*2);
  
  rightCalfTopRightX = rightThighBotRightX;
  rightCalfTopRightY = rightThighBotRightY;
  rightCalfBotLeftX = rightCalfTopRightX - (headWidth/2);
  rightCalfBotLeftY = rightCalfTopRightY + (headLength*2);
  
  leftCalfTopLeftX = leftThighBotLeftX;
  leftCalfTopLeftY = leftThighBotLeftY;
  leftCalfBotRightX = leftCalfTopLeftX + (headWidth/2);
  leftCalfBotRightY = leftCalfTopLeftY + (headLength*2);
  
  leftFootTopX = leftCalfBotRightX + (headWidth/4);
  leftFootTopY = leftCalfBotRightY;
  leftFootBotRightX = leftFootTopX;
  leftFootBotRightY = leftFootTopY + (headLength/3);
  leftFootBotLeftX = leftFootBotRightX - (headWidth*2);
  leftFootBotLeftY = leftFootBotRightY;
  
  rightFootTopX = rightCalfBotLeftX - (headWidth/4);
  rightFootTopY = rightCalfBotLeftY;
  rightFootBotLeftX = rightFootTopX;
  rightFootBotLeftY = rightFootTopY + (headLength/3);
  rightFootBotRightX = rightFootBotLeftX + (headWidth*2);
  rightFootBotRightY = rightFootBotLeftY;
  
  leftUpperArmTopRightX = shoulderLeftX;
  leftUpperArmTopRightY = shoulderLeftY;
  leftUpperArmBotLeftX = leftUpperArmTopRightX - headWidth/3;
  leftUpperArmBotLeftY = leftUpperArmTopRightY + int(headLength*1.5);

  rightUpperArmTopLeftX = shoulderRightX;
  rightUpperArmTopLeftY = shoulderRightY;
  rightUpperArmBotRightX = rightUpperArmTopLeftX + headWidth/3;
  rightUpperArmBotRightY = rightUpperArmTopLeftY + int(headLength*1.5);
  
  leftLowerArmTopLeftX = leftUpperArmBotLeftX;
  leftLowerArmTopLeftY = leftUpperArmBotLeftY;
  leftLowerArmBotRightX =leftLowerArmTopLeftX - headWidth/3;
  leftLowerArmBotRightY = leftLowerArmTopLeftY + int(headLength*1.5);

  rightLowerArmTopRightX = rightUpperArmBotRightX;
  rightLowerArmTopRightY = rightUpperArmBotRightY;
  rightLowerArmBotLeftX = rightLowerArmTopRightX + headWidth/3;
  rightLowerArmBotLeftY = rightLowerArmTopRightY + int(headLength*1.5);
  

 /* Translation list key:
  [TorsoX, TorsoY, NeckX, NeckY, HeadX, HeadY, LeftUpperArmX, LeftUpperArmY, LeftLowerArmX, ...
  [    0,     1,     2,      3,    4,      5,        6,             7,             8,         
... LeftLowerArmY, RightUpperArmX, RightUpperArmY, RightLowerArmX, RightLowerArmY, RightThighX, ...
        9,               10,             11,             12,             13,           14, 
...  RightThighY, RightCalfX, RightCalfY, RightFootX, RightFootY, LeftThighX, LeftThighY, ...
           15,        16,          17,        18,         19,         20,         21,
... LeftCalfX, LeftCalfY, LeftFootX, LeftfootY]
         22,      23,        24,        25    ]
*/
  pivots[0]=width/2; //torso
  pivots[1]=int(2.5*headLength)+height/8;
  pivots[2]=pivots[0]; //neck
  pivots[3]=pivots[1]-(torsoHeight/2);
  pivots[4]=pivots[2];//head
  pivots[5]=pivots[3]-(headLength/2);
  pivots[6]=pivots[0]-(torsoTopWidth/2); //left upper arm
  pivots[7]=pivots[1]-(torsoHeight/2);
  pivots[8]=pivots[6];//left lower arm
  pivots[9]=pivots[7]+int(headLength*1.5);
  pivots[10]=pivots[0]+(torsoTopWidth/2); //right upper arm
  pivots[11]=pivots[1]-(torsoHeight/2);
  pivots[12]=pivots[10]; //right lower arm
  pivots[13]=pivots[11]+int(headLength*1.5);
  pivots[14]=pivots[0]+(torsoBotWidth/2); //right thigh
  pivots[15]=pivots[1]+(torsoHeight/2);
  pivots[16]=pivots[14]; //right calf
  pivots[17]=pivots[15]+(headLength*2);
  pivots[18]=pivots[16]; //right foot
  pivots[19]=pivots[17]+(headLength*2);
  pivots[20]=pivots[0]-(torsoBotWidth/2); //left thigh
  pivots[21]=pivots[1]+(torsoHeight/2);
  pivots[22]=pivots[20]; //left calf
  pivots[23]=pivots[21]+(headLength*2);
  pivots[24]=pivots[22]; //left foot
  pivots[25]=pivots[23]+(headLength*2);
  
}

void updateSnow(){
  for(int i=0; i<46; i+=2){
    snowLocations[i+1] += 10;
    snowLocations[i]+=wind;
    if(snowLocations[i+1]>=height){
      snowLocations[i+1]=0;
    }
    if(snowLocations[i]>=width){
      snowLocations[i]=0;
    }
    
  }
}

/*
****** Draw Functions
****** Draw Functions
*/
void drawSnow(){
  ellipseMode(CENTER);
  for(int i =0; i<46; i+=2){
    //print("snowLocations"+i+": "+snowLocations[i]+", "+snowLocations[i+1]);
    circle(snowLocations[i], snowLocations[i+1], random(10,50));
  }
}

void drawHead(){
  switch(rotatingFlag){
    case 0: translate[4]=pivots[0]; translate[5]= pivots[1]; //if torso rotates
      break;
    case 1: translate[4]=pivots[2]; translate[5]=pivots[3]; //if neck rotates
      break;
    case 2: translate[4]=pivots[4]; translate[5]=pivots[5]; //if head rotates
      break;
  }
  translate(translate[4], translate[5]);
  rotate(rotate[2]);
  ellipseMode(CENTER);
 // ellipse(headSpotX, headSpotY, headWidth, headLength);
 ellipse(pivots[4]-translate[4], pivots[5]-(headLength/2)-translate[5], headWidth, headLength);
  rotate(-rotate[2]);
  translate(-translate[4], -translate[5]);
}

void drawNeck(){
  //if neck rotates because body rotates, make it spin around body center
  if(rotatingFlag ==0){
    translate[2] = pivots[0];
    translate[3] = pivots[1];
  }
  //if neck rotates itself, make it spin around lower neck point
  if(rotatingFlag ==1){
    translate[2]=pivots[2];
    translate[3]=pivots[3];
  }
  translate(translate[2], translate[3]);
  rotate(rotate[1]);
  //triangle(neckTopX, neckTopY, neckBotLeftX, neckBotLeftY, neckBotRightX, neckBotRightY);
  triangle(pivots[2]-translate[2], pivots[3]-neckHeight-translate[3],
  pivots[2]-(neckWidth/2)-translate[2], pivots[3]-translate[3],
  pivots[2]+(neckWidth/2)-translate[2], pivots[3]-translate[3]);
  
  rotate(-rotate[1]);
  translate(-translate[2], -translate[3]);
}

void drawTorso(){
  if(rotatingFlag==0){
    translate[0] = pivots[0];
    translate[1] = pivots[1];
  }
  translate(translate[0], translate[1]);
  rotate(rotate[0]);
  //quad(shoulderLeftX, shoulderLeftY, shoulderRightX, shoulderRightY, hipRightX, hipRightY,
  //hipLeftX, hipLeftY);
  quad(pivots[0]-(torsoTopWidth/2)-translate[0], pivots[1]-(torsoHeight/2)-translate[1],
  pivots[0]+(torsoTopWidth/2)-translate[0], pivots[1]-(torsoHeight/2)-translate[1],
  pivots[0]+(torsoBotWidth/2)-translate[0], pivots[1]+(torsoHeight/2)-translate[1],
  pivots[0]-(torsoBotWidth/2)-translate[0], pivots[1]+(torsoHeight/2)-translate[1]);
  
  rotate(-rotate[0]);
  translate(-translate[0], -translate[1]);
}

void drawThighs(){
  switch(rotatingFlag){
  case 0: translate[14]=pivots[0]; translate[15]=pivots[1];//torso rotates
          translate[20]=pivots[0]; translate[21]=pivots[1];
    break;
  case 7: translate[14]=pivots[14]; translate[15]=pivots[15];//right thigh rotates
    break;
  case 10: translate[20]=pivots[20]; translate[21]=pivots[21];//left thigh rotates
    break;
  }
  
  ellipseMode(CORNERS);
  translate(translate[20],translate[21]); //left thigh
  rotate(rotate[10]);
  //ellipse(leftThighTopRightX, leftThighTopRightY, leftThighBotLeftX, leftThighBotLeftY);
  ellipse(pivots[20]-translate[20], pivots[21]-translate[21],
  pivots[20]-(headWidth/2)-translate[20], pivots[21]+(headLength*2)-translate[21]);
  rotate(-rotate[10]);
  translate(-translate[20],-translate[21]);
  translate(translate[14], translate[15]);
  rotate(rotate[7]);
  //ellipse(rightThighTopLeftX, rightThighTopLeftY, rightThighBotRightX, rightThighBotRightY);
  ellipse(pivots[14]-translate[14], pivots[15]-translate[15],
  pivots[14]+(headWidth/2)-translate[14], pivots[15]+(headLength*2)-translate[15]);
  rotate(-rotate[7]);
  translate(-translate[14], -translate[15]);
}

void drawCalves(){
  switch(rotatingFlag){
  case 0: translate[16]=pivots[0]; translate[17]=pivots[1];//torso rotates
          translate[22]=pivots[0]; translate[23]=pivots[1];
    break;
  case 7: translate[16]=pivots[14]; translate[17]=pivots[15];//right thigh rotates
    break;
  case 10: translate[22]=pivots[20]; translate[23]=pivots[21];//left thigh rotates
    break;
  case 8: translate[16]=pivots[16]; translate[17]=pivots[17];//right calf rotates
    break;
  case 11: translate[22]=pivots[22]; translate[23]=pivots[23];//left calf rotates
    break;
  }
  ellipseMode(CORNERS);
  translate(translate[22], translate[23]);
  rotate(rotate[11]);
  //ellipse(leftCalfTopLeftX, leftCalfTopLeftY, leftCalfBotRightX, leftCalfBotRightY);
  ellipse(pivots[22]-translate[22], pivots[23]-translate[23],
  pivots[22]-(headWidth/2)-translate[22], pivots[23]+(headLength*2)-translate[23]);
  rotate(-rotate[11]);
  translate(-translate[22], -translate[23]);
  translate(translate[16], translate[17]);
  rotate(rotate[8]);
  //ellipse(rightCalfTopRightX, rightCalfTopRightY, rightCalfBotLeftX, rightCalfBotLeftY);
  ellipse(pivots[16]-translate[16], pivots[17]-translate[17],
  pivots[16] +(headWidth/2)-translate[16], pivots[17]+(headLength*2)-translate[17]);
  rotate(-rotate[8]);
  translate(-translate[16], -translate[17]);
}

void drawFeet(){
  switch(rotatingFlag){
  case 0: translate[18]=pivots[0]; translate[19]=pivots[1];//torso rotates
          translate[24]=pivots[0]; translate[25]=pivots[1];
    break;
  case 7: translate[18]=pivots[14]; translate[19]=pivots[15];//right thigh rotates
    break;
  case 10: translate[24]=pivots[20]; translate[25]=pivots[21];//left thigh rotates
    break;
  case 8: translate[18]=pivots[16]; translate[19]=pivots[17];//right calf rotates
    break;
  case 11: translate[24]=pivots[22]; translate[25]=pivots[23];//left calf rotates
    break;
  case 9: translate[18]=pivots[18]; translate[19] = pivots[19]; //right foot rotates
    break;
  case 12: translate[24]=pivots[24]; translate[25]=pivots[25]; //left foot rotates
  break;
  }
  translate(translate[18], translate[19]);
  rotate(rotate[9]);
  triangle(pivots[18]-translate[18], pivots[19]-translate[19], pivots[18]-translate[18],
  pivots[19]+(headLength/3)-translate[19], pivots[18]+(headWidth*2)-translate[18],
  pivots[19]+(headLength/3)-translate[19]);
  rotate(-rotate[9]);
  translate(-translate[18], -translate[19]);
  translate(translate[24], translate[25]);
  rotate(rotate[12]);
  //triangle(leftFootTopX, leftFootTopY, leftFootBotRightX, leftFootBotRightY, leftFootBotLeftX, leftFootBotLeftY);
  triangle(pivots[24]-translate[24], pivots[25]-translate[25], pivots[24]-translate[24],
  pivots[25]+(headLength/3)-translate[25], pivots[24]-(headWidth*2)-translate[24],
  pivots[25]+(headLength/3)-translate[25]);
  rotate(-rotate[12]);
  translate(-translate[24], -translate[25]);
}

void drawUpperArms(){
 switch(rotatingFlag){
   case 0: translate[6]=pivots[0]; translate[7]=pivots[1];//torso rotates
           translate[10]=pivots[0]; translate[11]=pivots[1];
     break;
   case 3: translate[6]=pivots[6]; translate[7]=pivots[7];//left upper arm rotates
     break;
   case 5: translate[10]=pivots[10]; translate[11]=pivots[11];//right upper arm rotates
     break;
 }
  ellipseMode(CORNERS);
  translate(translate[10], translate[11]);
  rotate(rotate[5]);
  //ellipse(rightUpperArmTopLeftX, rightUpperArmTopLeftY, rightUpperArmBotRightX, rightUpperArmBotRightY);
  ellipse(pivots[10]-translate[10], pivots[11]-translate[11],
  pivots[10]+ (headWidth/3)-translate[10], pivots[11]+int(headLength*1.5)-translate[11]);
  rotate(-rotate[5]);
  translate(-translate[10], -translate[11]);
  translate(translate[6], translate[7]);
  rotate(rotate[3]);
  //ellipse(leftUpperArmTopRightX, leftUpperArmTopRightY, leftUpperArmBotLeftX, leftUpperArmBotLeftY);
  ellipse(pivots[6]-translate[6], pivots[7]-translate[7], pivots[6]-(headWidth/3)-translate[6],
  pivots[7]+int(headLength*1.5)-translate[7]);
  rotate(-rotate[3]);
  translate(-translate[6], -translate[7]);
}

void drawLowerArms(){
  switch(rotatingFlag){
   case 0: translate[8]=pivots[0]; translate[9]=pivots[1];//torso rotates
           translate[12]=pivots[0]; translate[13]=pivots[1];
     break;
   case 3: translate[8]=pivots[6]; translate[9]=pivots[7];//left upper arm rotates
     break;
   case 5: translate[12]=pivots[10]; translate[13]=pivots[11];//right upper arm rotates
     break;
   case 4: translate[8]=pivots[8]; translate[9]=pivots[9]; //left lower arm rotates
     break;
   case 6: translate[12]=pivots[12]; translate[13]=pivots[13];//right lower arm rotates
     break;
 }
  ellipseMode(CORNERS);
  translate(translate[12], translate[13]);
  rotate(rotate[6]);
  ellipse(pivots[12]-translate[12], pivots[13]-translate[13],
  pivots[12]+(headWidth/3)-translate[12], pivots[13]+int(headLength*1.5)-translate[13]);
  rotate(-rotate[6]);
  translate(-translate[12], -translate[13]);
  translate(translate[8], translate[9]);
  rotate(rotate[4]);
  ellipse(pivots[8]-translate[8], pivots[9]-translate[9],
  pivots[8]-(headWidth/3)-translate[8], pivots[9]+int(headLength*1.5)-translate[9]);
  rotate(-rotate[4]);
  translate(-translate[8], -translate[9]);
}


  
/*Transformation Controls
/*
Rotation list / rotatingFlags list key:

  [Torso, Neck, Head, LeftUpperArm, LeftLowerArm, RightUpperArm, RightLowerArm, RightThigh, ...
  [   0,   1,    2,        3,          4,               5,             6,           7,      ...
... RightCalf, RightFoot, LeftThigh, LeftCalf, LeftFoot]
...    8,        9,         10,          11,      12   ]
*/
void setRotateList(int index, float shift){
  //println("rotating index: " + str(index) + " Shift amount: " + str(shift));
  switch (index){
    case 0: for(int i=0; i<13; i++){rotate[i]+=shift;} rotatingFlag=0; break;
    case 1: rotate[1] += shift; rotate[2]+=shift; rotatingFlag=1; break;
    case 2: rotate[2] +=shift; rotatingFlag=2; break;
    case 3: rotate[3] +=shift; rotate[4]+=shift; rotatingFlag=3; break;
    case 4: rotate[4] +=shift; rotatingFlag=4; break;
    case 5: rotate[5] +=shift; rotate[6]+=shift; rotatingFlag=5; break;
    case 6: rotate[6] +=shift; rotatingFlag=6; break;
    case 7: rotate[7] += shift; rotate[8]+=shift; rotate[9]+=shift; rotatingFlag=7; break;
    case 8: rotate[8] += shift; rotate[9] +=shift; rotatingFlag=8; break;
    case 9: rotate[9] +=shift; rotatingFlag=9; break;
    case 10: rotate[10] +=shift; rotate[11]+=shift; rotate[12]+=shift; rotatingFlag=10; break;
    case 11: rotate[11]+= shift; rotate[12] +=shift; rotatingFlag=11; break;
    case 12: rotate[12] += shift; rotatingFlag=12; break;
  }
    // println(rotate);
}
/*unachieved functionality involved with hierarchical repositioning of pivot points 
int newX(int initX, int initY, float rotation,int Xtranslation, int Ytranslation){
  int newLocation = int(((Ytranslation+initY)*sin(rotation))+
  ((Xtranslation+initX)*cos(rotation)));
  return(newLocation);
}
int newY(int initX, int initY, float rotation,int Xtranslation, int Ytranslation){
  int newLocation = int(((Ytranslation+initY)*cos(rotation))+
  ((Xtranslation+initX)*sin(rotation)));
  return(newLocation);
}*/


//speed 4sec period - 0.3sec period
void spin(){ //direction: 0 for left, 1 for right
  if(spinTimer>0){
     spinTimer--;
     spinAngle=360/(speed*100);
     if(direction==1){spinAngle = -spinAngle;}
     setRotateList(spinPart, radians(spinAngle));
   }
   else{
   readNewSerial=1;
   spinTimer=300;
   }
}

void parseSerialLine(){
  String line = port.readString();
  println(line);
  String[]parsed=split(line, ',');
  for(int i=0; i<parsed.length; i++){print(parsed[i]);}
  switch(parsed[0]){
    case "ESP1": //TMP#,HMD#,PIZ#
      int temp = int(split(parsed[1],'P')[1]);
      int hum = int(split(parsed[2],'D')[1]);
      print("parsed3 "+parsed[3]);
      //int piezo = int(split(parsed[3], 'Z')[1]);
      if(hum>20){
        direction=0;}
      else{
        direction=1;}
      speed=map(temp,0, 40, 0.3,4);
      //spinPart = int(map(piezo, 0, 4096, 0, 12));
      spinPart = int(map(random(0,4096), 0, 4096, 0, 12));
      spinTimer=int(100*speed);      
      break;
    case "ESP2": //DRA#
      int doorA = int(split(parsed[1],'A')[1]);
      direction = doorA==0 ? (direction+1)%2 : direction;
      spinPart=0;
    break;
    case "ESP3": //DRB#
      int doorB = int(split(parsed[1],'B')[1]);
      snowColor = doorB==0 ? int(random(255)) : snowColor;
      spinPart= second()%13;
    break;
    case "ESP4": //USN#
      float slider = float(split(parsed[1],'N')[1]);
      backColor = int(map(slider, 0, 4200, 0, 255));
      wind=int(map(slider, 0,4200,0, 50));
      spinPart=minute()%13;
  }
}

//keyboard control for testing purposes
/*void keyPressed(){
  if(key == 'a'){
    spin(0, 1, 0.5);
    //setRotateList(0, radians(10));
  }
  if(key == 's'){
    spin(0, 0, 4);
    //setRotateList(1, radians(10));
  }
  if(key == 'd'){
    setRotateList(2, radians(10));
  }
  if(key == 'f'){
    setRotateList(3, radians(10));
  }
  if(key == 'g'){
    setRotateList(4, radians(10));
  }
  
  if(key == 'h'){
    setRotateList(5, radians(10));
  }
  if(key == 'j'){
    setRotateList(6, radians(10));
  }
  if(key == 'k'){
    setRotateList(7, radians(10));
  }
  if(key == 'l'){
    setRotateList(8, radians(10));
  }
  if(key == 'z'){
    setRotateList(9, radians(10));
  }
  if(key == 'x'){
    setRotateList(10, radians(10));
  }
  if(key == 'c'){
    setRotateList(11, radians(10));
  }
  if(key == 'v'){
    setRotateList(12, radians(10));
  }
  
}
*/
