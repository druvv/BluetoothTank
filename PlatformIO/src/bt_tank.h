// Method definitions

// Command Parsing
void handleChar(char c);
void executeCommand();

void stopAll();

// Motor speeds
void motorOrientationTest();
void setLeft(int s);
void setRight(int s);

// Passes usb input to bluetooth and vice versa.
void syncBTandUSB();