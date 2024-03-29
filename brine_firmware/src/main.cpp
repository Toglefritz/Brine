#include <Arduino.h>

#include "DebugService.h"


void setup() {
  // Get the DebugService instance. This will initialize the Serial connection.
  DebugService& debugService = DebugService::getInstance();

  // Use the debugService to print messages
  debugService.debugPrintln("Setup complete");
}

void loop() {
  // put your main code here, to run repeatedly:
}