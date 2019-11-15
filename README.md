# Our Mesh Network Set Up

We are connecting our ESP32s via a mesh network in which one four ESPs collect sensor data and relay it to one receiver ESP which then relays all of the messages on the network to a Raspberry Pi over serial communication. Once this is done, that Raspberry Pi can either host its own visualization/actualization or broadcast the sensor data to other Raspberry Pis on the network for other visualizations.

The space that we have decided to take over is the entrance as it is the busiest part of the entire building and there is much data to be collected from within and outside the building. Outside there will be two ESPs, one collecting temperature and humidity data, and sensing ambient light. On the entrance door there will be a hall sensor that triggers when the door is opened/closed. Lastly, in the lobby there will be one ultrasonic sensor that senses an objects proximity to it. Below is a diagram of our layout.

![Mesh Diagram](https://github.com/gracec10/meshsystem/blob/master/meshDiagram.png)