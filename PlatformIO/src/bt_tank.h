// Method definitions

// Command Parsing
void handleChar(char c);
void executeCommand();

void stopAll();

// Timing
void timeTick();

// Air pump
void startCharging();
void stopCharging();

// Solenoid
void openSolenoid();
void closeSolenoid();

// Motor speeds
void motorOrientationTest();
void setLeft(int s);
void setRight(int s);

// Bluetooth
// Respond with a message;
void respond(char c);
// Passes usb input to bluetooth and vice versa.
void syncBTandUSB();