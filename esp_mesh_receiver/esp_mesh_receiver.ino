#include <painlessMesh.h>
#include <AsyncTCP.h>

Scheduler userScheduler; // to control your personal task
painlessMesh mesh;

#define   MESH_SSID     "ces-mesh"
#define   MESH_PASSWORD   "goodbyemark"
#define   MESH_PORT       5555

void receivedCallback( uint32_t from, String &msg ) {
  Serial.printf("%u,%s\n", from, msg.c_str());
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
