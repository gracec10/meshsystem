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
#define id 2 //Set the ID of the ESP32 within the context of the system
#define HTS 0 //Set the HTS temp/humidity sensor pin. Set to 0 if this ESP does not have this sensor.
#define HAL 34 //Set the Hall sensor pin. Set to 0 if this ESP does not have this sensor.
#define LIT 0 //Set the photoresistor pin. Set to 0 if this ESP does not have this sensor.
#define USN 0 //Set the ultrasonic distance sensor trigger pin. Set to 0 if this ESP does not have this sensor.
#define USE 0 //Set the ultrasonic distance sensor echo pin. If the trigger pin is set to 0 this will be ignored.  Set to 0 if this ESP does not have this sensor.

//Set up sensor variables 
DHTesp dht;
TaskHandle_t tempTaskHandle = NULL;
Ultrasonic ultrasonic(USN, USE, 40000UL);
int hallState = 0;
int lightValue;
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
  if(HTS != 0) { //Add temp / humidity values
    TempAndHumidity lastValues = dht.getTempAndHumidity();
    if(lastValues.humidity <= 100) {
      toSend.concat(",TMP" + String(lastValues.temperature,0));
      toSend.concat(",HMD" + String(lastValues.humidity,0));
    }
  };
  if(HAL != 0) { //Add hall sensor value
    toSend.concat(",HAL" + String(digitalRead(HAL)));

  };
  if(LIT != 0) { //Add photoresistor value
    toSend.concat(",LIT" + String(analogRead(LIT)));
  };
  if(USN != 0 && USE != 0) { //Add ultrasonic value
    toSend.concat(",USN" + String(ultrasonic.read()));
  };
  toSend.concat("\n");
  mesh.sendBroadcast(toSend);

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
  if(HAL != 0) {
    pinMode(HAL,INPUT);
  };
}

void loop() {
  mesh.update();
}
