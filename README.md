# Our Mesh Network Set Up

We are connecting our ESP32s via a mesh network in which one four ESPs collect sensor data and relay it to one receiver ESP which then relays all of the messages on the network to a Raspberry Pi over serial communication. Once this is done, that Raspberry Pi can either host its own visualization/actualization or broadcast the sensor data to other Raspberry Pis on the network for other visualizations.

The space that we have decided to take over is the entrance as it is the busiest part of the entire building and there is much data to be collected from within and outside the building. Outside is a single ESP collecting temperature and humidity data, and vibrations via a piezoelectric sensor. On the two entrance doors there will be hall sensors that triggers when the doors open/close. Lastly, on the left side of the lobby is a sliding potentiometer that gives different values based on how you slide it. Below is a diagram of our layout.

![Mesh Diagram](https://github.com/gracec10/meshsystem/blob/master/meshDiagram.png)