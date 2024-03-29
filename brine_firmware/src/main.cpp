#include <Arduino.h>

#include "DebugService.h"
#include "DeviceManager.h"

// Define a callback function for the button press events.
void buttonCallback() {
    // TODO(Toglefritz): Code to execute when the button is pressed
}

void setup() {
  // Get the DebugService instance. This will initialize the Serial connection if it hasn't been done yet
  // and if debug mode is enabled via the Platform IO build system.
  DebugService& debugService = DebugService::getInstance();

  // Initialize the devices with the button callback
  DeviceManager::initDevices(buttonCallback);

  // Use the debugService to print messages
  debugService.debugPrintln("Brine monitor setup complete.");
}

void loop() {
  // Put your main code here, to run repeatedly:
}