// Need to install ArduinoJSON and TaskScheduler as well

#include <painlessMesh.h>
#include <AsyncTCP.h>
#include <DHTesp.h>
#include <Ultrasonic.h>


/* The below section should be changed for each individual 
 *  ESP32 depending on its configuration. If the ESP has the 
 *  particular sensor as listed below, it should be replaced 
 *  with the pin value of that sensor. Otherwise, set the 
 *  value to 0 and it will be ignored. This is for consistent
 *  formatting across messages sent and logged with the network.
 */
#define id 8 //Set the ID of the ESP32 within the context of the system
#define HTS 0 //Set the HTS temp/humidity sensor pin. Set to 0 if this ESP does not have this sensor. ESP-ID 1
#define DRA 0 //Set the door 1 sensor pin. Set to 0 if this ESP does not have this sensor. ESP-ID 2
#define DRB 0 //Set the door 2 sensor pin. Set to 0 if this ESP does not have this sensor. ESP-ID 3
#define PIZ 0 //Set the piezo wind pin. Set to 0 if this ESP does not have this sensor. ESP-ID 1
#define POT 34 //Set the sliding potentiometer pin. Set to 0 if this ESP does not have this sensor. ESP-ID 4

//Set up sensor variables 
DHTesp dht;
TaskHandle_t tempTaskHandle = NULL;
int potValue = 0;
int piezoValue =0 ;
String toSend;

Scheduler userScheduler; // to control your personal task
painlessMesh mesh;

#define   MESH_SSID     "ces-mesh"
#define   MESH_PASSWORD   "goodbyemark"
#define   MESH_PORT       5555

// User stub
void sendMessage(); // Prototype so PlatformIO doesn't complain

Task taskSendMessage( TASK_SECOND * 1 , TASK_FOREVER, &sendMessage );

void sendMessage() {
  toSend = "ESP" + String(id);
  int sending = 1;
  if(HTS != 0) { //Add temp / humidity values
    TempAndHumidity lastValues = dht.getTempAndHumidity();
    if(lastValues.humidity <= 100) {
      toSend.concat(",TMP" + String(lastValues.temperature,0));
      toSend.concat(",HMD" + String(lastValues.humidity,0));
    } else {
      sending = 0;
    };
  };
  if(DRA != 0) { //Add door 1 sensor value
    toSend.concat(",DRA" + String(digitalRead(DRA)));

  };
   if(DRB != 0) { //Add door 2 sensor value
    toSend.concat(",DRB" + String(digitalRead(DRB)));

  };
  if(PIZ != 0) { //Add piezo wind value 
    toSend.concat(",PIZ" + String(analogRead(PIZ)));
  };
  if(POT != 0) { //Add potentiometer slider value
    toSend.concat(",USN" + String(analogRead(POT)));
  };
  toSend.concat("\n");
  if(sending = 1) {
    mesh.sendBroadcast(toSend);
  };

  taskSendMessage.setInterval(500);
}

void receivedCallback( uint32_t from, String &msg ) {
  Serial.printf(" Message Received %d: %s", from, msg.c_str());
}

void newConnectionCallback(uint32_t nodeId) {
  Serial.printf("--> startHere: New Connection, nodeId = %u\n", nodeId);
}

void changedConnectionCallback() {
  Serial.printf("Changed connections\n");
}

void nodeTimeAdjustedCallback(int32_t offset) {
  Serial.printf("Adjusted time %u. Offset = %d\n", mesh.getNodeTime(), offset);
}


void setup() {
  Serial.begin(115200);
  mesh.setDebugMsgTypes( ERROR | STARTUP );
  mesh.init( MESH_SSID, MESH_PASSWORD, &userScheduler, MESH_PORT );

  mesh.onReceive(&receivedCallback);
  mesh.onNewConnection(&newConnectionCallback);
  mesh.onChangedConnections(&changedConnectionCallback);
  mesh.onNodeTimeAdjusted(&nodeTimeAdjustedCallback);

  userScheduler.addTask( taskSendMessage );
  taskSendMessage.enable();
  if(HTS != 0) {
    dht.setup(HTS, DHTesp::DHT11);
  };
  if(DRA != 0) {
    pinMode(DRA,INPUT);
  };
  if(DRB != 0) {
    pinMode(DRB,INPUT);
  };
  if(POT != 0){
    pinMode(POT,INPUT);
  }
}

void loop() {
  mesh.update();
}
