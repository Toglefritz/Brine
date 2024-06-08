#include <Arduino.h>

#include "DebugService.h"
#include <BLEModule.h>
#include <I2CButton.h>
#include <I2CLED.h>
#include <ProvisioningManager.h>
#include <Wire.h>

// Determines if the button was pressed. This bool is set to true when the button is pressed and set to false again 
// when the provisioning process been running for three minutes or more.
volatile bool buttonPressed = false;

// A timestamp for when the provisioning process was started. This is used to create a timeout for the provisioning 
// process to prevent it from running indefinitely if no provisioning activities are detected.
unsigned long provisioningStartTime = 0;

// Determines if a client device is connected to the BLE server. While a client is connected, the provisioning process
// should not be interrupted.
bool clientConnected = false;

/**
 * @brief Interrupt service routine for the button.
 *
 * This function is called when the button interrupt is triggered.
 * It sets the `buttonPressed` flag to true.
 *
 * @note This function should be kept as short as possible to prevent blocking the main loop and causing the ESP32 to 
 * reset due to a watchdog timeout.
 */
void IRAM_ATTR button_isr() { buttonPressed = true; }

/**
 * @brief Initializes the provisioning manager and sets up Bluetooth callbacks.
 *
 * This function initializes the `ProvisioningManager` singleton instance and sets up the external Bluetooth event 
 * callbacks for connection, disconnection, characteristic read, characteristic write, and descriptor write events. 
 * These callbacks are used to handle the respective events within the main application logic. After configuring the
 * callbacks, the provisioning process is started by calling the `startProvisioning` method of the `ProvisioningManager` 
 * instance.
 *
 * The function also sets the provisioning start time to the current time (in milliseconds), which can be used for 
 * timeout management or other time-based operations during the provisioning process.
 *
 * The callbacks are set up as follows:
 *  - Connection callback: Logs a message and handles the connection event.
 *  - Disconnection callback: Logs a message and handles the disconnection event.
 *  - Write callback: Logs the written value and handles the write event.
 *  - Read callback: Logs a message and handles the read event.
 *  - Descriptor write callback: Logs whether notifications have been enabled or disabled 
 *    and handles the descriptor write event.
 */
void startProvisioning() {
    // Initialize provisioning manager
    ProvisioningManager &provManager = ProvisioningManager::getInstance();

    // Set external callbacks
    provManager.setExternalConnectionCallback([](BLEServer *pServer) {
        // Set the flag to indicate that a client is connected.
        clientConnected = true;
    });

    provManager.setExternalDisconnectionCallback([](BLEServer *pServer) {
        // When a client is disconnected, stop the provisioning process early.
        DebugService::getInstance().debugPrintln(
            "Client disconnected. Stopping provisioning process.");

        ProvisioningManager::getInstance().stopProvisioning();

        // Turn off the LED in case it was on at the time of the timeout.
        I2CLED::getInstance().turnOff();

        // Reset the provisioning start time and button pressed flags.
        provisioningStartTime = 0;
        buttonPressed = false;
        clientConnected = false;
    });

    provManager.setExternalWriteCallback(
        [](BLECharacteristic *pCharacteristic) {
            std::string value = pCharacteristic->getValue();
            DebugService::getInstance().debugPrint(
                "Main: Characteristic written: ");
            DebugService::getInstance().debugPrintln(value.c_str());

            // Handle write event in main
        });

    provManager.setExternalReadCallback([](BLECharacteristic *pCharacteristic) {
        DebugService::getInstance().debugPrintln("Main: Characteristic read");

        // Handle read event in main
    });

    provManager.setExternalDescriptorWriteCallback(
        [](BLEDescriptor *pDescriptor) {
            uint8_t *data = pDescriptor->getValue();
            if (data[0] == 0x01) {
                DebugService::getInstance().debugPrintln(
                    "Main: Notifications enabled");
            } else if (data[0] == 0x00) {
                DebugService::getInstance().debugPrintln(
                    "Main: Notifications disabled");
            }
            // Handle descriptor write event in main
        });

    // Start the provisioning process.
    provManager.startProvisioning();

    // Set the provisioning start time to the current time.
    provisioningStartTime = millis();
}

void setup() {
    // Join the I2C bus
    Wire.begin();

    // Initialize the button service, setting the buttonCallback function as the callback for button presses.
    I2CButton::getInstance().begin(button_isr);

    // Initialize the LED service.
    I2CLED::getInstance().begin();

    // Turn the LED off initially.
    I2CLED::getInstance().turnOff();

    // Use the debugService to print messages.
    DebugService::getInstance().debugPrintln("Brine monitor setup complete.");

    // TODO(Toglefritz): Get and send information to Brine backend
}

void loop() {
    // Start the provisioning process if the button was pressed and the provisioning process has not already started.
    if (buttonPressed && provisioningStartTime == 0) {
        startProvisioning();
    }
    // If more than three minutes has passed since the provisioning process started, turn off provisioning.
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
    // If the provisioning process is currently running, but a client is not connected yet, blink the LED.
    else if (provisioningStartTime != 0 && !clientConnected) {
        I2CLED::getInstance().blink(millis());
    }
    // If the provisioning process is currently running, and a client is connected, turn on the LED.
    else if (provisioningStartTime != 0 && clientConnected) {
        I2CLED::getInstance().turnOn();
    }

    // TODO(Toglefritz): Add additional loop functionality
}