#include <Arduino.h>

#include "DebugService.h"
#include <BLEModule.h>
#include <I2CButton.h>
#include <I2CLED.h>
#include <ProvisioningManager.h>
#include <Wire.h>

// Determines if the button was pressed. This bool is set to true when the
// button is pressed and set to false again when the provisioning process been
// running for three minutes or more.
volatile bool buttonPressed = false;

// A timestamp for when the provisioning process was started. This is used to
// create a timeout for the provisioning process to prevent it from running
// indefinitely if no provisioning activities are detected.
unsigned long provisioningStartTime = 0;

/**
 * @brief Interrupt service routine for the button.
 *
 * This function is called when the button interrupt is triggered.
 * It sets the `buttonPressed` flag to true.
 *
 * @note This function should be kept as short as possible to prevent blocking
 * the main loop and causing the ESP32 to reset due to a watchdog timeout.
 */
void IRAM_ATTR button_isr() { buttonPressed = true; }

void setup() {
    // Join the I2C bus
    Wire.begin();

    // Initialize the button service, setting the buttonCallback function as the
    // callback for button presses.
    I2CButton::getInstance().begin(button_isr);

    // Initialize the LED service.
    I2CLED::getInstance().begin();

    // Use the debugService to print messages.
    DebugService::getInstance().debugPrintln("Brine monitor setup complete.");

    // TODO(Toglefritz): Get and send information to Brine backend
}

void loop() {
    // Start the provisioning process if the button was pressed and the
    // provisioning process has not already started.
    if (buttonPressed && provisioningStartTime == 0) {
        ProvisioningManager::getInstance().startProvisioning();

        // Set the provisioning start time to the current time.
        provisioningStartTime = millis();
    }
    // If more than three minutes has passed since the provisioning process
    // started, turn off provisioning.
    // TODO(Toglefritz): also check for provisioning activity
    else if (provisioningStartTime != 0 &&
             millis() - provisioningStartTime >= 180000) {
        DebugService::getInstance().debugPrintln(
            "Provisioning process timed out. Turning off provisioning.");

        ProvisioningManager::getInstance().stopProvisioning();

        // Turn off the LED in case it was on at the time of the timeout.
        I2CLED::getInstance().turnOff();

        // Reset the provisioning start time and button pressed flags.
        provisioningStartTime = 0;
        buttonPressed = false;

        // Reset the state of the button.
        I2CButton::getInstance().clearEventBits();
    }
    // If the provisioning process is currently running, blink the LED.
    else if (provisioningStartTime != 0) {
        I2CLED::getInstance().blink(millis());
    }

    // TODO(Toglefritz): Add additional loop functionality
}