#include <painlessMesh.h>
#include <AsyncTCP.h>

Scheduler userScheduler; // to control your personal task
painlessMesh mesh;

#define   MESH_SSID     "ces-mesh"
#define   MESH_PASSWORD   "goodbyemark"
#define   MESH_PORT       5555

void receivedCallback( uint32_t from, String &msg ) {
  Serial.printf("%s\n", vtpFormat(msg.c_str()));
}

void newConnectionCallback(uint32_t nodeId) {
//  Serial.printf("--> startHere: New Connection, nodeId = %u\n", nodeId);
}

void changedConnectionCallback() {
//  Serial.printf("Changed connections\n");
}

void nodeTimeAdjustedCallback(int32_t offset) {
//  Serial.printf("Adjusted time %u. Offset = %d\n", mesh.getNodeTime(), offset);
}


void setup() {
  Serial.begin(115200);
  mesh.setDebugMsgTypes( ERROR | STARTUP );
  mesh.init( MESH_SSID, MESH_PASSWORD, &userScheduler, MESH_PORT );

  mesh.onReceive(&receivedCallback);
  mesh.onNewConnection(&newConnectionCallback);
  mesh.onChangedConnections(&changedConnectionCallback);
  mesh.onNodeTimeAdjusted(&nodeTimeAdjustedCallback);
}

void loop() {
  mesh.update();
}

String vtpFormat(String str) {
  String output = "";
  String[] splat = split(str, ',');

  if (splat[0].substring(0,3).equals("ESP") == true) {
    if (splat[1].equals("HTS") == true) {
      output = "A ";
    }
    if (splat[1].substring(0,3).equals("DRA") == true) {
      output = "B ";
    }
    if (splat[1].substring(0,3).equals("DRB") == true) {
      output = "C ";
    }
    if (splat[1].substring(0,3).equals("PIZ") == true) {
      output = "D ";
    }
    if (splat[1].substring(0,3).equals("POT") == true) {
      output = "E ";
    }
    output = output + splat[1].substring(3);
    return output;
  }
  else return "B 0";
}

//int digitalSensor,analogSensor;
//
//void setup() {
//  pinMode(7, INPUT); //configure digital pin as input
//  digitalWrite(7, HIGH);
//  Serial.begin(57600);
//  delay(100);
//  Serial.flush();
//  delay(1000);
//  Serial.println(-1,DEC); //send -1 to let VPT serial port is ready
//}
//
//void loop() {
//  analogSensor = analogRead(5);
//  digitalSensor= digitalRead(7);
//  // delay 10ms to let the ADC recover:
//  delay(10);
//  Serial.print("A ");
//  Serial.println(analogSensor, DEC);
//  Serial.print("B ");
//  Serial.println(digitalSensor, DEC);
//}

//private class parser {
//  public int id;
//  public int TMP;
//  public int HMD;
//  public int DRA;
//  public int DRB;
//  public int PIZ;
//  public int USN;
//  
//  
//  parser() {  
//  }
//  
//  void parse(String str) {
//    String[] list = split(str, ',');
//    for(int i = 0; i < list.length; i++) {
//      if (list[i].substring(0,3).equals("ESP") == true) {
//        this.id = parseInt(list[i].substring(3, list[i].length()));
//      } else if (list[i].substring(0,3).equals("TMP") == true) {
//        this.TMP = parseInt(list[i].substring(3, list[i].length()));
//      } else if (list[i].substring(0,3).equals("HMD") == true) {
//        this.HMD = parseInt(list[i].substring(3, list[i].length()));
//      } else if (list[i].substring(0,3).equals("DRA") == true) {
//        this.DRA = parseInt(list[i].substring(3, list[i].length()));
//      } else if (list[i].substring(0,3).equals("DRB") == true) {
//        this.DRB = parseInt(list[i].substring(3, list[i].length()));
//      } else if (list[i].substring(0,3).equals("PIZ") == true) {
//        this.PIZ = parseInt(list[i].substring(3, list[i].length()));
//      } else if (list[i].substring(0,3).equals("USN") == true) {
//        this.USN = parseInt(list[i].substring(3, list[i].length()));
//      }
//    }
//  }
//}
