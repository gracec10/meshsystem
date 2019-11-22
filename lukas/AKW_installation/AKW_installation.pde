import processing.serial.*;

Serial myPort;  // The serial port
String serialLine = null;
float doorW;
float doorH;

door doors[] = new door[2];

parser p = new parser();

int new_line = 10;

float[] col = new float[3];


int temp_range = 50;
int humd_range = 100;
int piz_range = 4095;
int pot_range = 1024;

float light_value;

int last_DRA = 0;
int last_DRB = 0;

void setup() {
  fullScreen(P3D);
  //size(400,400);
  doorH = height / 1.5;
  doorW = width / 90;
  lights();
  doors[0] = new door(255, 255, 255, height/2, height / 2, 0.1, 0, 0, 0);
  doors[1] = new door(255, 255, 255, width - (height / 2), height / 2, 0.1, 0, 0, 0);
  
  // List all the available serial ports
  printArray(Serial.list());
  // Open the port you are using at the rate you want:
  myPort = new Serial(this, Serial.list()[7], 115200);
  myPort.clear();
  // Throw out the first reading, in case we started reading 
  // in the middle of a string from the sender.
  serialLine = myPort.readStringUntil(new_line);
  serialLine = null;  

}

void draw() {
 
   while (myPort.available() > 0) {
    serialLine = myPort.readStringUntil(new_line);
    if (serialLine != null) {
         serialLine = serialLine.substring(0, serialLine.length()-1); 
         p.parse(serialLine);
         rend(p);
         
         //println(p.DRA);
    }
  }
}

void rend(parser p) {
  hsv2rgb(map(p.USN, 0, pot_range, 0, 1.0), 1.0, map(p.PIZ, 0, piz_range, 0, 1.0), col); 
  
  background(255,255,255);
  
  light_value = map(p.TMP, 0, temp_range, 0, 255);
  //ambientLight(light_value,light_value,light_value);
  fill(col[0], col[1], col[2], map(p.HMD, 0, humd_range, 0, 255));
  rect(0, 0, width, height);
  if (p.DRA == 0 && last_DRA == 1) {
    doors[1].open();
  }  
  if (p.DRB == 0 && last_DRB == 1) {
    doors[0].open();
  }
  doors[0].drawMe();
  doors[1].drawMe();
  
   last_DRA = p.DRA;
   last_DRB = p.DRB;
   delay(50);
}

float fract(float x) { return x - int(x); }
float mix(float a, float b, float t) { return a + (b - a) * t; }
float[] hsv2rgb(float h, float s, float b, float[] rgb) {
  rgb[0] = 255 * b * mix(1.0, constrain(abs(fract(h + 1.0) * 6.0 - 3.0) - 1.0, 0.0, 1.0), s);
  rgb[1] = 255 * b * mix(1.0, constrain(abs(fract(h + 0.6666666) * 6.0 - 3.0) - 1.0, 0.0, 1.0), s);
  rgb[2] = 255 * b * mix(1.0, constrain(abs(fract(h + 0.3333333) * 6.0 - 3.0) - 1.0, 0.0, 1.0), s);
  return rgb;
}

private class parser {
  public int id;
  public int TMP;
  public int HMD;
  public int DRA;
  public int DRB;
  public int PIZ;
  public int USN;
  
  
  parser() {  
  }
  
  void parse(String str) {

    String[] list = split(str, ',');
    for(int i = 0; i < list.length; i++) {

      if (list[i].length() > 3) {
        
            //println(list);
        if (list[i].substring(0,3).equals("ESP") == true) {
          this.id = parseInt(list[i].substring(3, list[i].length()));
        } else if (list[i].substring(0,3).equals("TMP") == true) {
          this.TMP = parseInt(list[i].substring(3, list[i].length()));
        } else if (list[i].substring(0,3).equals("HMD") == true) {
          this.HMD = parseInt(list[i].substring(3, list[i].length()));
        } else if (list[i].substring(0,3).equals("DRA") == true) {
          this.DRA = parseInt(list[i].substring(3, list[i].length()));
        } else if (list[i].substring(0,3).equals("DRB") == true) {
          this.DRB = parseInt(list[i].substring(3, list[i].length()));
        } else if (list[i].substring(0,3).equals("PIZ") == true) {
          this.PIZ = parseInt(list[i].substring(3, list[i].length()));
        } else if (list[i].substring(0,3).equals("USN") == true) {
          this.USN = parseInt(list[i].substring(3, list[i].length()));
        }
        
      }

    }
  }
}

private class door {
  private int r;
  private int g;
  private int b;
  private float x;
  private float y;
  private float z;
  private float xd;
  private float yd;
  private float zd;
  private boolean opening;
  private boolean closing;
  private int open_count = 0;
  
  door(int nr, int ng, int nb, float nx, float ny, float nz, float nxd, float nyd, float nzd) {
    this.r = nr;
    this.g = ng;
    this.b = nb;
    this.x = nx;
    this.y = ny;
    this.z = nz;
    this.xd = nxd;
    this.yd = nyd;
    this.zd = nzd;
    this.opening = false;
    this.closing = false;
  }
  
  void drawMe() {
    if (this.opening && !this.closing) {
      this.yd += 0.1;
      this.open_count++;
      if (this.open_count > 15 ) {
        this.opening = false;
        this.colour(255, 0, 0);
        this.closing = true;
      }

    }
    
    if (!this.opening && this.closing) {
      this.yd -= 0.1;
      this.open_count--;
      if (this.open_count == 0 ) {
        println("here");
        this.opening = false;
        this.colour(255, 255, 255);
        this.closing = false;
      }

    }
    
    pushMatrix();
    fill(this.r, this.g, this.b);
    translate(this.x, this.y, this.z);
    rotateY(this.yd);
    rotateX(this.xd);
    rotateZ(this.zd);
    stroke(0, 0, 0);
    box(doorW, doorH, 200);
    popMatrix();
  }
  
  void reset() {
      this.open_count = 0;
      this.opening = false;
      this.colour(0, 0, 255);
  }
  
  void colour(int nr, int ng, int nb) {
    this.r = nr;
    this.g = ng;
    this.b = nb;
  }
  
  void open() {
    if (this.closing == false) {
      this.colour(0, 0, 255);
      this.opening = true;
    }

  }
}
