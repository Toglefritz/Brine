#include <Arduino.h>

#include "DeviceConfig.h"

#include "DebugService.h"
#include <BLEApiHandler.h>
#include <BLEModule.h>
#include <BatteryMonitor.h>
#include <DeepSleepService.h>
#include <DeviceConfigurationManager.h>
#include <DistanceSensor.h>
#include <I2CButton.h>
#include <I2CLED.h>
#include <Wire.h>

/// An I2CButton instance used to handle button presses.
I2CButton &button = I2CButton::getInstance();

// Determines if the button was pressed. This bool is set to true when the button is pressed and set to false again
// when the provisioning process been running for three minutes or more.
volatile bool buttonPressed = false;

// If the button is held down for this duration, the device will perform a reset.
const unsigned long LONG_PRESS_DURATION = 10000; // 10,000 milliseconds = 10 seconds

// Variables to track button press timing
unsigned long buttonPressStartTime = 0;
bool isLongPressTriggered = false;

// A timestamp for when the provisioning process was started. This is used to create a timeout for the provisioning
// process to prevent it from running indefinitely if no provisioning activities are detected.
unsigned long provisioningStartTime = 0;

// Determines if a client device is connected to the BLE server. While a client is connected, the provisioning process
// should not be interrupted.
bool clientConnected = false;

/**
 * @brief Interrupt service routine for the button.
 *
 * This function is called when the button interrupt is triggered. It sets the `buttonPressed` flag to true.
 *
 * @note This function should be kept as short as possible to prevent blocking the main loop and causing the ESP32 to
 * reset due to a watchdog timeout.
 */
void IRAM_ATTR button_isr() { buttonPressed = true; }

// A handler for Bluetooth API commands and responses.
BLEApiHandler apiHandler;

// A service for saving and reading values from the non-volatile storage (NVS) of the ESP32.
NVSService &nvsService = NVSService::getInstance();

// A service for sending information to the Firebase cloud backend.
FirebaseService firebaseService;

// A service for getting readings from the distance sensor used to determine the salt level in the water softener based
// on the distance of the salt level from the sensor compared to the overall height of the water softener.
DistanceSensor sensor;

// A service for getting the remaining battery life of the device based on a voltage divider connected to the battery.
BatteryMonitor batteryMonitor();

// A service for interacting with the cryptographic coprocessor.
CryptoService cryptoService;

/**
 * @brief Updates the device salt and battery levels in the Firebase cloud.
 *
 * This function retrieves the salt and battery levels from the device's sensors and sends them to the Firebase cloud
 * backend via a POST request. The function uses the `FirebaseService` singleton instance to send the data.
 *
 * @note This function will fail if the device is not connected to the internet.
 *
 * @return true if the data was successfully uploaded to the Firebase cloud, false otherwise.
 */
bool _updateDeviceLevels() {
  DebugService::getInstance().debugPrintln("Updating device levels...");

  // Get the "salt level" from the distance sensor.
  float saltLevel = sensor.getDistance();

  // Stop the distance sensor's operations.
  sensor.stopMeasurement();

  // Create a BatteryMonitor instance
  BatteryMonitor batteryMonitor;

  // Get the remaining battery life percentage using the BatteryMonitor
  float batteryLife = batteryMonitor.getBatteryLifePercent();

  // Upload the salt and battery levels to the Firebase cloud
  bool success = firebaseService.uploadSensorData(batteryLife, saltLevel);

  if (success) {
    DebugService::getInstance().debugPrintln("Device levels successfully updated in Firebase.");
  } else {
    DebugService::getInstance().debugPrintln("Failed to update device levels in Firebase.");
  }

  return success;
}

/**
 * @brief Initializes the device configuration manager and sets up Bluetooth callbacks.
 *
 * This function initializes the `DeviceConfigurationManager` singleton instance and sets up the external Bluetooth
 * event callbacks for connection, disconnection, characteristic read, characteristic write, and descriptor write
 * events. These callbacks are used to handle the respective events within the main application logic. After
 * configuring the callbacks, the provisioning process is started by calling the `startProvisioning` method of the
 * `DeviceConfigurationManager` instance.
 *
 * The function also sets the provisioning start time to the current time (in milliseconds), which can be used for
 * timeout management or other time-based operations during the provisioning process.
 *
 * The callbacks are set up as follows:
 *  - Connection callback: Logs a message and handles the connection event.
 *  - Disconnection callback: Logs a message and handles the disconnection event.
 *  - Write callback: Logs the written value and handles the write event.
 *  - Read callback: Logs a message and handles the read event.
 *  - Descriptor write callback: Logs whether notifications have been enabled or disabled and handles the descriptor
 *    write event.
 */
void startProvisioning() {
  // Initialize provisioning manager
  DeviceConfigurationManager &deviceConfigManager = DeviceConfigurationManager::getInstance();

  // Set external callbacks
  deviceConfigManager.setExternalConnectionCallback([](BLEServer *pServer) {
    // Turn on the LED.
    I2CLED::getInstance().turnOn();

    // Set the flag to indicate that a client is connected.
    clientConnected = true;
  });

  deviceConfigManager.setExternalDisconnectionCallback([](BLEServer *pServer) {
    // When a client is disconnected, stop the provisioning process early.
    DebugService::getInstance().debugPrintln("Client disconnected. Stopping provisioning process.");

    DeviceConfigurationManager::getInstance().stopProvisioning();

    // Turn off the LED in case it was on at the time of the timeout.
    I2CLED::getInstance().turnOff();

    // Reset the provisioning start time and button pressed flags.
    provisioningStartTime = 0;
    buttonPressed = false;
    clientConnected = false;
  });

  // Set the write callback for handling characteristic write events.
  deviceConfigManager.setExternalWriteCallback([&deviceConfigManager](BLECharacteristic *pCharacteristic) {
    std::string value = pCharacteristic->getValue();

    // Handle the JSON command using BLEApiHandler
    String jsonResponse = apiHandler.handleCommand(String(value.c_str()));
    deviceConfigManager.setCharacteristicValue(pCharacteristic, jsonResponse.c_str());
  });

  // Set the read callback for handling characteristic read events.
  deviceConfigManager.setExternalReadCallback([](BLECharacteristic *pCharacteristic) {
    DebugService::getInstance().debugPrintln("Main: Characteristic read");

    // Handle read event in main
  });

  // Set the descriptor write callback for handling descriptor write events.
  deviceConfigManager.setExternalDescriptorWriteCallback([](BLEDescriptor *pDescriptor) {
    uint8_t *data = pDescriptor->getValue();
    if (data[0] == 0x01) {
      DebugService::getInstance().debugPrintln("Main: Notifications enabled");
    } else if (data[0] == 0x00) {
      DebugService::getInstance().debugPrintln("Main: Notifications disabled");
    }
    // Handle descriptor write event in main
  });

  // Set a callback for handling completion of the provisioning process upon receiving a command from the client
  // indicating that all tasks have been completed.
  apiHandler.setProvisioningCompleteCallback([]() {
    DebugService::getInstance().debugPrintln("Provisioning complete. Stopping provisioning process.");

    // Stop the provisioning process.
    DeviceConfigurationManager::getInstance().stopProvisioning();

    // Turn off the LED in case it was on at the time of the timeout.
    I2CLED::getInstance().turnOff();

    // Upload the salt and battery levels to the cloud.
    _updateDeviceLevels();
    // TODO handle the upload process failing

    // Reset the provisioning start time and button pressed flags.
    provisioningStartTime = 0;
    buttonPressed = false;
    clientConnected = false;
  });

  // Start the provisioning process.
  deviceConfigManager.startProvisioning();

  // Set the provisioning start time to the current time.
  provisioningStartTime = millis();
}

// Function to trigger system reboot
void triggerSystemReboot() {
  DebugService::getInstance().debugPrintln("Long button press detected. Rebooting system...");
  // Perform any necessary cleanup here

  // Clear NVS before rebooting (if desired)
  nvsService.eraseAll();

  // Delay to ensure messages are sent before reboot
  delay(1000);

  // Reboot the ESP32
  ESP.restart();
}

/**
 * @brief Connect to the saved WiFi credentials.
 *
 * This function attempts to retrieve the saved WiFi credentials from the NVS service and connect to the WiFi network.
 * The function first checks if the WiFi credentials are available in the NVS service. If the credentials are found, the
 * function attempts to connect to the WiFi network using the retrieved SSID and password. If the connection is
 * successful, the function prints a success message. If the connection fails, the function prints an error message.
 * If the WiFi credentials are not found in the NVS service, the function prints a message indicating that the
 * credentials are not available.
 *
 * @return true if the device successfully connects to the WiFi network, false otherwise.
 */
bool connectToSavedWiFi() {
  JsonDocument retrievedDoc;
  // Retrieve the JSON document stored under the key "wifiCredentials"
  bool retrieveResult = nvsService.retrieveJSON("wifiCredentials", retrievedDoc);
  if (retrieveResult) {
    DebugService::getInstance().debugPrintln("WiFi credentials retrieved successfully.");

    // Attempt to connect to WiFi using the retrieved credentials.
    WiFi.begin(retrievedDoc["ssid"].as<String>().c_str(), retrievedDoc["password"].as<String>().c_str());

    // Wait for connection with a timeout
    unsigned long startTime = millis();
    const unsigned long timeout = 15000; // 15 seconds timeout

    while (WiFi.status() != WL_CONNECTED && millis() - startTime < timeout) {
      delay(500); // Wait for 500ms before checking again
      DebugService::getInstance().debugPrint(".");
    }

    DebugService::getInstance().debugPrintln(""); // End of dots

    if (WiFi.status() == WL_CONNECTED) {
      DebugService::getInstance().debugPrintln("WiFi connected successfully.");
      DebugService::getInstance().debugPrint("IP Address: ");
      DebugService::getInstance().debugPrintln(WiFi.localIP().toString());
      return true;
    } else {
      DebugService::getInstance().debugPrintln("Failed to connect to WiFi within the timeout.");
      return false;
    }
  } else {
    DebugService::getInstance().debugPrintln("No WiFi credentials found in NVS.");
    return false;
  }
}

/**
 * @brief Configures the deep sleep management service.
 *
 * This function configures the service that handles the deep sleep cycle for the Brine device. The service handles
 * placing the device into a deep sleep state and setting up the conditions under which it will wake up. When the
 * device wakes, callback functions are invoked.
 */
void _configureDeepSleepService() {
  DeepSleepService &deepSleepService = DeepSleepService::getInstance();

  // Set the duration to sleep between sensor uploads. In debug mode, this duration is 30 seconds to allow for faster
  // iterations during development. In production, the device waits 24 hours between sensor readings.
  int deepSleepDuration = DebugService::getInstance().DEBUG ? 30000 : 86400000;

  // Configure wake-up sources. The first argument is a duration in milliseconds for the timer wake-up. The second is
  // a GPIO pin used to manually wake up the device.
  deepSleepService.configureWakeUp(deepSleepDuration, GPIO_NUM_32);

  // Enter deep sleep.
  deepSleepService.enterDeepSleep();
}

/**
 * @brief The setup function for the Brine monitor firmware.
 */
void setup() {
  // Join the I2C bus
  Wire.begin();

  // Initialize the button service, setting the buttonCallback function as the callback for button presses.
  button.begin(button_isr);

  // Initialize the LED service.
  I2CLED::getInstance().begin();

  // Turn the LED off initially.
  I2CLED::getInstance().turnOff();

  // Initialize the distance sensor.
  bool sensorInitialized = sensor.begin();
  if (!sensorInitialized) {
    DebugService::getInstance().debugPrintln("Failed to initialize distance sensor.");
  } else {
    DebugService::getInstance().debugPrintln("Distance sensor initialized.");
  }

  // Initialize the cryptographic coprocessor.
  bool cryptoInitialized = cryptoService.begin();
  if (!cryptoInitialized) {
    DebugService::getInstance().debugPrintln("Failed to initialize cryptographic coprocessor.");
  } else {
    DebugService::getInstance().debugPrintln("Cryptographic coprocessor initialized.");
  }

  // Initialize NVSService with the "wifi_credentials" namespace.
  if (!nvsService.begin("wifi")) {
    DebugService::getInstance().debugPrintln("NVS Service initialization failed.");
    // TODO Handle initialization failure
  } else {
    DebugService::getInstance().debugPrintln("NVS Service initialized successfully.");
  }

  // Use the debugService to print messages.
  DebugService::getInstance().debugPrintln("Brine monitor setup complete.");

  // Initialize the device ID
  String deviceId = DEVICE_ID;
  DebugService::getInstance().debugPrint("Device ID: ");
  DebugService::getInstance().debugPrintln(deviceId);

  // Print the MAC address of the device for debugging purposes.
  DebugService::getInstance().debugPrint("MAC address: ");
  DebugService::getInstance().debugPrintln(WiFi.macAddress());

  // Print the device name for debugging purposes.
  DebugService::getInstance().debugPrint("Device name: ");
  DebugService::getInstance().debugPrintln(DeviceName::getDeviceName());

  // Attempt to connect to WiFi with retries
  bool wifiConnected = false;
  const int maxRetries = 5; // Number of retries
  int retryCount = 0;

  while (!wifiConnected && retryCount < maxRetries) {
    DebugService::getInstance().debugPrint("Attempting to connect to WiFi... (Attempt ");
    DebugService::getInstance().debugPrint(String(retryCount + 1).c_str());
    DebugService::getInstance().debugPrintln(")");

    wifiConnected = connectToSavedWiFi();

    if (!wifiConnected) {
      DebugService::getInstance().debugPrintln("WiFi connection failed. Retrying...");
      delay(5000); // Wait before retrying
      retryCount++;
    }
  }

  if (!wifiConnected) {
    DebugService::getInstance().debugPrintln("Failed to connect to WiFi after multiple attempts.");
    // Optionally reset the device or enter deep sleep here
    _configureDeepSleepService();
    return; // Exit setup if WiFi connection fails
  }

  DebugService::getInstance().debugPrintln("WiFi connected successfully.");

  // Capture sensor readings and send them to the cloud backend.
  if (!_updateDeviceLevels()) {
    DebugService::getInstance().debugPrintln("Failed to upload device levels to Firebase.");
    // Handle upload failure if needed
  }

  // Configure the deep sleep service.
  _configureDeepSleepService();
}

void loop() {
  // Start the provisioning process if the button was pressed and the provisioning process has not already started.
  if (buttonPressed && provisioningStartTime == 0) {
    // Record the time when the button was pressed
    buttonPressStartTime = millis();
    buttonPressed = false; // Reset the flag

    // Start the provisioning process.
    startProvisioning();
  }
  // Check if provisioning is ongoing
  if (provisioningStartTime != 0) {
    // If more than three minutes has passed since the provisioning process started, and a client is not connected,
    // turn off provisioning process.
    if (millis() - provisioningStartTime >= 180000 && !clientConnected) { // 3 minutes
      DebugService::getInstance().debugPrintln("Provisioning process timed out. Turning off provisioning.");

      DeviceConfigurationManager::getInstance().stopProvisioning();

      // Turn off the LED in case it was on at the time of the timeout.
      I2CLED::getInstance().turnOff();

      // Reset the provisioning start time and button pressed flags.
      provisioningStartTime = 0;
      buttonPressed = false;

      // Reset the state of the button.
      I2CButton::getInstance().clearEventBits();
    } else if (!clientConnected) {
      // Blink LED while provisioning
      I2CLED::getInstance().blink(millis());
    }
  }

  // Detect long button press
  if (buttonPressStartTime != 0) {
    // Check if the button is still being held down
    if (button.isPressed()) {
      // Check if the duration exceeds the long press threshold
      if (!isLongPressTriggered && (millis() - buttonPressStartTime >= LONG_PRESS_DURATION)) {
        isLongPressTriggered = true;
        triggerSystemReboot();
      }
    } else {
      // Button was released before long press duration
      buttonPressStartTime = 0;
      isLongPressTriggered = false;
    }
  }

  // If the provisioning process is currently running, but a client is not connected yet, blink the LED.
  if (provisioningStartTime != 0 && !clientConnected) {
    I2CLED::getInstance().blink(millis());
  }

  // Ensure that the LED is off when provisioning is not running.
  if (provisioningStartTime == 0) {
    I2CLED::getInstance().turnOff();
  }
}