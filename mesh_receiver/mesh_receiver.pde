import oscP5.*;
import netP5.*;

OscP5 osc;

String msgValue; // msg storing osc messages

void setup() {
  size(100, 100);

  osc = new OscP5(this, 33333); // set up listener
}


// on oscEvent parse and print msg
void oscEvent(OscMessage oscMsg) {
  print("New msg:");
  println(" addrpattern: "+oscMsg.addrPattern());

  msgValue = oscMsg.get(0).stringValue();

  println(msgValue);
}
