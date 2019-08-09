#include <Arduino.h>
#include "bt_tank.h"
#include "SoftwareSerial.h"
#include "Servo.h"

// Pin Macros
#define AIR_PUMP_PIN 9
#define SOLENOID_PIN 39
#define HORIZONTAL_SERVO_PIN 2
#define VERTICAL_SERVO_PIN 4
#define BT_STATE_PIN 39

// - Motor H-Bridge Pins
#define MOTOR_A_EN 45
#define MOTOR_A_IN1 52
#define MOTOR_A_IN2 51
#define MOTOR_B_IN3 50
#define MOTOR_B_IN4 49
#define MOTOR_B_EN 44

// Rx1 <-> BT TX
// Tx1 <-> BT RX through voltage divider
char c=' ';
boolean NL = true;

unsigned long currTime;
unsigned long airPumpStartTime;

/*
+------------------------------------------------------------------+
|                             Commands                             |
+---------+---------------------------+----------------------------+
| Command |        Description        |          Response          |
+---------+---------------------------+----------------------------+
|    L    |      Left Motor Speed     |            None            |
+---------+---------------------------+----------------------------+
|    R    |     Right Motor Speed     |            None            |
+---------+---------------------------+----------------------------+
|    S    |       Solenoid Fire       |           fired\n          |
+---------+---------------------------+----------------------------+
|    A    |    Air Pump Charge Time   |  when received: charging\n |
|         |                           |  when finished: charged\n  |
+---------+---------------------------+----------------------------+
|    V    |  Vertical Servo Position  |            None            |
+---------+---------------------------+----------------------------+
|    H    | Horizontal Servo Position |            None            |
+---------+---------------------------+----------------------------+
 */


char incomingChar;
const char END_COMMAND_CHAR = '\n';
String serialBuffer = "";

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  Serial1.begin(9600);

  // Pin init
  pinMode(BT_STATE_PIN, INPUT);

  // Wait for serial pins to initialize
  while (!Serial && !Serial1) {}
  Serial.println("System started!");
}

boolean motorTestStarted = false;

void loop() {
  //syncBTandUSB();
  //motorOrientationTest();

  /* 
  // If we disconnect from bluetooth, stop everything.
  if (digitalRead(BT_STATE_PIN) == LOW) {
    stopAll();
    return;
  }
  */

  // Check if we have characters from either USB or bluetooth.
  if (Serial.available() > 0 ) {
     incomingChar = Serial.read();
     handleChar(incomingChar);
  } else if (Serial1.available() > 0) {
     incomingChar = Serial1.read();
     handleChar(incomingChar);
  }
}

// Command Parsing

void handleChar(char c) {
  // If we reach the end of the command execute the command
  if (c == END_COMMAND_CHAR) {
    executeCommand();
    return;
  }
  // Append to buffer
  serialBuffer += c;
}

// Reads the command from the buffer and then clears it;
void executeCommand() {

  char commandCode = serialBuffer[0];
  int commandEnd = serialBuffer.indexOf('\n', 1);
  String commandText = serialBuffer.substring(1, commandEnd);
  int commandValue = commandText.toInt();

  switch (commandCode) {
    case 'L':
      setLeft(commandValue);
      break;
    case 'R':
      setRight(commandValue);
      break;
    case 'S':
      break;
    case 'A':
      break;
    case 'V':
      break;
    case 'H':
      break;
    default:
      break;
  }

  // Clear Serial Buffer
  serialBuffer = "";
}

void stopAll() {
  setLeft(0);
  setRight(0);
}

// - MARK: Motor Speeds

void motorOrientationTest() {
  if (!motorTestStarted) {
    setLeft(100);
    setRight(100);
    motorTestStarted = true;
  }
}

// s should be in between -255 and 255
void setLeft(int s) {
  if (s > 0) {
    digitalWrite(MOTOR_A_IN1, HIGH);
    digitalWrite(MOTOR_A_IN2, LOW);
  } else if (s < 0) {
    digitalWrite(MOTOR_A_IN1, LOW);
    digitalWrite(MOTOR_A_IN2, HIGH);
  } else {
    digitalWrite(MOTOR_A_IN1, LOW);
    digitalWrite(MOTOR_A_IN2, LOW);
  }

  s = abs(s);
  analogWrite(MOTOR_A_EN, s);
}

// s should be in between -255 and 255
void setRight(int s) {
  if (s > 0) {
    digitalWrite(MOTOR_B_IN3, LOW);
    digitalWrite(MOTOR_B_IN4, HIGH);
  } else if (s < 0)  {
    digitalWrite(MOTOR_B_IN3, HIGH);
    digitalWrite(MOTOR_B_IN4, LOW);
  } else {
    digitalWrite(MOTOR_B_IN3, LOW);
    digitalWrite(MOTOR_B_IN4, LOW);
  }

  s = abs(s);
  analogWrite(MOTOR_B_EN, s);
}

// Passes usb input to bluetooth and vice versa.
void syncBTandUSB() {
  // Read from the Bluetooth module and send to the Arduino Serial Monitor
    if (Serial1.available())
    {
        c = Serial1.read();
        Serial.write(c);
    }
 
 
     // Read from the Serial Monitor and send to the Bluetooth module
    if (Serial.available())
    {
        c = Serial.read();
 
        // do not send line end characters to the HM-10
        if (c!=10 & c!=13 ) 
        {  
             Serial1.write(c);
        }
 
        // Echo the user input to the main window. 
        // If there is a new line print the ">" character.
        if (NL) { Serial.print("\r\n>");  NL = false; }
        Serial.write(c);
        if (c==10) { NL = true; }
    }
}