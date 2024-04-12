#include <Arduino.h>

#include "DebugService.h"
#include <BLEModule.h>
#include <Wire.h>
#include <I2CButton.h>

// Determines if the button was pressed. This bool is set to true when the button is pressed and set to false again
// when the provisioning process been running for three minutes or more.
volatile bool buttonPressed = false;

// A timestamp for when the provisioning process was started. This is used to create a timeout for the provisioning
// process to prevent it from running indefinitely if no provisioning activities are detected.
unsigned long provisioningStartTime = 0;

/**
 * @brief Interrupt service routine for the button.
 *
 * This function is called when the button interrupt is triggered.
 * It sets the `buttonPressed` flag to true.
 * 
 * @note This function should be kept as short as possible to prevent blocking the main loop and
 * causing the ESP32 to reset due to a watchdog timeout.
 */
void IRAM_ATTR button_isr() {
    buttonPressed = true;
}

/**
 * @brief Initializes Bluetooth communication, which is used during the provisioning process.
*/
void initializeBluetooth() {
    // Initialize the BLEModule
    bool bleBeginSuccess = BLEModule::getInstance().begin();

    if (!bleBeginSuccess) {
        DebugService::getInstance().debugPrintln("Failed to initialize BLE module.");
        return;
    }

    // Begin advertising over BLE
    bool bleAdvertiseSuccess = BLEModule::getInstance().advertise();

    if (!bleAdvertiseSuccess) {
        DebugService::getInstance().debugPrintln("Failed to start advertising.");
        return;
    }

    DebugService::getInstance().debugPrintln("Started advertising over BLE.");
}

/**
 * @brief Starts the provisioning process.
 * 
 * This function is called when the button is pressed to initiate the provisioning process.
 * It wakes up the ESP32 from deep sleep and initializes the Bluetooth system.
 */
void startProvisioning() {
    DebugService::getInstance().debugPrintln("Button pressed. Starting provisioning process.");

    // TODO(Toglefritz): Wake up the ESP32 from deep sleep.

    // Initialize the Bluetooth system.
    initializeBluetooth();

    // Set the start time of the provisioning process.
    provisioningStartTime = millis();
}

void setup() {
  // Join the I2C bus
  Wire.begin();

  // Initialize the button service, setting the buttonCallback function as the callback for button presses.
  I2CButton::getInstance().begin(button_isr);

  // TODO(Toglefritz): Add additional setup

  // Use the debugService to print messages.
  DebugService::getInstance().debugPrintln("Brine monitor setup complete.");

  // TODO(Toglefritz): Get and send information to Brine backend
}

void loop() {
    // Start the provisioning process if the button was pressed and the provisioning process has not already started.
    if (buttonPressed && provisioningStartTime == 0) {
        startProvisioning();
        provisioningStartTime = millis();
    }
    // If more than three minutes have passed since the provisioning process started, turn off provisioning.
    // TODO(Toglefritz): also check for provisioning activity
    else if (provisioningStartTime != 0 && millis() - provisioningStartTime >= 180000) {
        DebugService::getInstance().debugPrintln("Provisioning process timed out. Turning off provisioning.");

        provisioningStartTime = 0;
        buttonPressed = false;
    }

   // TODO(Toglefritz): Add additional loop functionality
}