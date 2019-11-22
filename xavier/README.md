# Emotion Box

This piece is called Emotion Box and is representative of how I feel about the CS Department at Yale. My main motivation behind this project to explore VPT8, a projection mapping software. The things projected onto the screen represent different emotional states and are triggered via a mesh network of ESP32 Sensors.


## Install It Yourself!
(Good Luck)

In order to replicate this installation you'll need the following:

- The mesh network outlined in the root folder
- A device with Arduino IDE and VPT8 installed on it
- A projector
- A cardboard box and white paper to wrap it in 

First what you'll want to is clone this git repository. Make sure to set up the mesh network and install the four ESPs with sensors in your desired locations. Then flash the fifth ESP, the receiver, with the VTPSerial.ino. This is like the esp_mesh_receiver.ino file in the root folder, but with an additional function to format the serial messages for VPT8. Make sure to check the serial monitor within the Arduino IDE to ensure that you are receiving input from all your ESPs.

Then you will want to set up the box or space you are projecting onto and your projector, AND THEN NEVER MOVE IT AGAIN. This installation is super fragile in the sense that it moving the projector or box slightly will result in improperly mapped projections. To some small deviations will seem inconsequential, but it will drive perfectionists wild. 

Next you'll want to move into VPT8 click file > open > CESMapping > projectpath.maxpat. This sets up all the layers, cuelists, and serial controller presets that I defined for my project. However, you will likely need to reorient the projection layers as your projection set up (i.e. box, distance and angle of projector) will not match mine. To fix this, you may want to consult the following links.

There is a video tutorial of VPT8 at this link: https://www.youtube.com/watch?v=it2Haaam6U0
There is also detailed documentation at this link: http://nervousvision.com/VPT8documentation/index.html

Once the projections are properly mapped, sensor data can be read and interpetted from the serial tab in VPT8.