int randHMD;
int randTMP;
int  randPIZ;
int  randDRA;
int  randDRB;
int  randPOT;
int dataSelector;
String messages[4];
int n=1;

void setup() {
  Serial.begin(115200);
  randomizeData();
  dataSelector=int(random(5));
}

void loop() {
  Serial.println(messages[random(4)]);
  randomSeed(n);
  n++;
  randomizeData();
  delay(500);
  // put your main code here, to run repeatedly:

}

void randomizeData(){
  randHMD=int(random(0,50));
  randTMP=int(random(0,40));
  randPIZ=int(random(0,4020));
  randDRA=int(random(2));
  randDRB=int(random(2));
  randPOT=int(random(0,4000));

  messages[0]="ESP1,TMP"+String(randTMP)+",HMD"+String(randHMD)+",PIZ"+String(randPIZ);
  messages[1]="ESP2,DRA"+String(randDRA);
  messages[2]="ESP3,DRB"+String(randDRB);
  messages[3]="ESP4,POT"+String(randPOT);
}
