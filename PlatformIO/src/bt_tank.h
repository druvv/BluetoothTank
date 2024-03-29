
enum MountDirection { up, down, left, right, stop };

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

// Servo Mount
void attachServos();
void detachServos();
void moveMount(enum MountDirection direction);

// Motor speeds
void motorOrientationTest();
void setLeft(int s);
void setRight(int s);

// Bluetooth
void respond(char c);
void syncBTandUSB();