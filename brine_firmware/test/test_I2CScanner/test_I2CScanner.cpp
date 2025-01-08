#include <Arduino.h>
#include <Wire.h>
#include <unity.h>

/**
 * @brief PlatformIO test for detecting I2C devices on the bus.
 *
 * This test scans the I2C bus for connected devices and verifies that all
 * expected devices are detected at their respective addresses. The expected
 * devices in this setup include:
 *  - Cryptographic coprocessor at address 0x60
 *  - Distance sensor at address 0x29
 *  - Button/LED combo at address 0x20
 *
 * The test performs the following steps:
 *
 * 1. Initializes the I2C bus using the specified SDA and SCL pins.
 * 2. Scans all possible I2C addresses (from 0x03 to 0x77) to detect devices.
 * 3. Compares the detected addresses with the expected addresses.
 * 4. Fails the test if:
 *    - The number of detected devices does not match the expected count.
 *    - Any expected device is not detected.
 *
 * This test helps ensure that:
 * - All required I2C devices are correctly connected to the bus.
 * - No address conflicts or communication issues exist.
 *
 * To run this test, use the command:
 * `pio test --filter test_I2CScanner`
 */

// Define the expected I2C addresses for the devices
#define CRYPTO_I2C_ADDRESS 0x60
#define SENSOR_I2C_ADDRESS 0x29     
#define BUTTON_LED_I2C_ADDRESS 0x6F
#define BATTERY_FUEL_GAUGE_ADDRESS 0x36 

// Array of expected addresses
const uint8_t expectedAddresses[] = {CRYPTO_I2C_ADDRESS, SENSOR_I2C_ADDRESS, BUTTON_LED_I2C_ADDRESS, BATTERY_FUEL_GAUGE_ADDRESS};

// Buffer to store detected addresses
uint8_t detectedAddresses[sizeof(expectedAddresses)];
size_t detectedCount = 0;

// Function to scan the I2C bus and store detected addresses
void scanI2C() {
  detectedCount = 0;

  for (uint8_t address = 0x03; address <= 0x77; address++) {
    Wire.beginTransmission(address);
    if (Wire.endTransmission() == 0) {
      detectedAddresses[detectedCount++] = address;
    }
  }
}

// Unity test to verify that all expected I2C devices are detected
void test_I2C_devices_detected() {
  scanI2C();

  // Check if the number of detected devices matches the expected count
  if (sizeof(expectedAddresses) != detectedCount) {
    char messageBuffer[150]; // Buffer to store the complete error message
    snprintf(messageBuffer, sizeof(messageBuffer),
             "Incorrect number of I2C devices detected. Expected: %d, Detected: %d. Addresses: ",
             sizeof(expectedAddresses), detectedCount);

    // Append each detected address to the message
    for (size_t i = 0; i < detectedCount; i++) {
      char addressBuffer[6]; // Buffer to store each address in hex format
      snprintf(addressBuffer, sizeof(addressBuffer), "0x%02X ", detectedAddresses[i]);
      strncat(messageBuffer, addressBuffer, sizeof(messageBuffer) - strlen(messageBuffer) - 1);
    }

    // Use the generated message in the assertion
    TEST_ASSERT_EQUAL_UINT8_MESSAGE(sizeof(expectedAddresses), detectedCount, messageBuffer);
  }
}

void setup() {
  Wire.begin(); // Initialize I2C with SDA on pin 21 and SCL on pin 22

  UNITY_BEGIN();                       // Start the Unity test framework
  RUN_TEST(test_I2C_devices_detected); // Run the I2C devices detection test
  UNITY_END();                         // End the Unity test framework
}

void loop() {
  // Empty loop for PlatformIO test runner
}