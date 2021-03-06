import oscP5.*;
import netP5.*;
import processing.io.*;


//Define global variables
OscP5 oscP5;
NetAddress legoMotorServer;
final Integer UP = 1;
final Integer DOWN = 2;
Integer lastReceivedWand = 0;
Integer lastReceivedVoice = 0;

public void settings() {
    size(100, 100); // Note, this is just a blank window that can be closed without consequence 
}


void setup() {
    legoMotorServer = new NetAddress("127.0.0.1", 12001); //the IP and port that the motor server is listening on
  
    frameRate(0.01);
    /* start oscP5, listening for incoming messages at port 12000 */
    oscP5 = new OscP5(this, "0.0.0.0",  12000, OscP5.UDP);
}


/**
 * Recieve OSC messages from Wekinator
 */
void oscEvent(OscMessage theOscMessage) {
    if (theOscMessage.checkAddrPattern("/output_1") == true) {
        println("UP wand gesture recieved.");
        lastReceivedWand = UP;
        if (shouldCallElevator()) activateSolenoid(UP);
    }
    else if (theOscMessage.checkAddrPattern("/output_2") == true) {
        println("DOWN wand gesture recieved.");
        lastReceivedWand = DOWN;
        if (shouldCallElevator()) activateSolenoid(DOWN);
    }
    else if (theOscMessage.checkAddrPattern("/up_voice") == true) {
        println("UP voice command recieved.");
        lastReceivedVoice = UP;
        if (shouldCallElevator()) activateSolenoid(UP);
    }
    else if (theOscMessage.checkAddrPattern("/down_voice") == true) {
        println("DOWN voice command recieved.");
        lastReceivedVoice = DOWN;
        if (shouldCallElevator()) activateSolenoid(DOWN);
    }
}

/**
 * Check and manipulate global variables for wand and voice inputs
 * and return true when the wand and voice inputs match.
 */
Boolean shouldCallElevator() {
    if (lastReceivedWand == UP && lastReceivedVoice == UP) {
        lastReceivedWand = 0;
        lastReceivedVoice = 0;
        return true;
    } else if (lastReceivedWand == DOWN && lastReceivedVoice == DOWN) {
        lastReceivedWand = 0;
        lastReceivedVoice = 0;
        return true;
    } else if (lastReceivedWand == DOWN && lastReceivedVoice == UP) {
        lastReceivedWand = 0;
        lastReceivedVoice = 0;
        return false;
    } else if (lastReceivedWand == UP && lastReceivedVoice == DOWN) {
        lastReceivedWand = 0;
        lastReceivedVoice = 0;
        return false;
    } else {
        return false; 
    }
}


/**
 * Activate a solenoid based on which spell was cast
 */
void activateSolenoid(Integer spell) {
    if (spell == UP) {
        OscMessage upMessage = new OscMessage("/elevator/up");
        upMessage.add(0); //add random data to the osc message
        oscP5.send(upMessage, legoMotorServer);
        
        println("Elevator is called going up.\n");  
    }
    else if (spell == DOWN) {
        OscMessage downMessage = new OscMessage("/elevator/down");
        downMessage.add(0); //add random data to the osc message
        oscP5.send(downMessage, legoMotorServer);
        
        println("Elevator is called going down.\n");
    }
    else {
        // no-op
    }
}
