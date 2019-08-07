#include <Arduino.h>
#include "SoftwareSerial.h"
#include "Servo.h"

// Pin Macros
#define AIR_PUMP_PIN 9
#define SOLENOID_PIN 39
#define HORIZONTAL_SERVO_PIN 42
#define VERTICAL_SERVO_PIN 43
#define BT_RX 44
#define BT_TX 45
// - Motor H-Bridge Pins
#define MOTOR_A_EN 53
#define MOTOR_A_IN1 52
#define MOTOR_A_IN2 51
#define MOTOR_B_IN3 50
#define MOTOR_B_IN4 49
#define MOTOR_B_EN 48

SoftwareSerial btSerial = SoftwareSerial(BT_TX, BT_RX);


void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
  bluetoothSerial.begin(115200);
  // Wait for serial pins to initialize
  while (!Serial && !bluetoothSerial) {}
}

void loop() {
  syncBTandUSB();
}

// Passes usb input to bluetooth and vice versa.
void syncBTandUSB() {
  if Serial.available() > 0 {
    char s = Serial.read();
    btSerial.write(s);
  }

  if btSerial.available() > 0 {
    char b = btSerial.read();
    Serial.write(b);
  }
}