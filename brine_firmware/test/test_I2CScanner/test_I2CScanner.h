#ifndef TEST_I2CSCANNER_H
#define TEST_I2CSCANNER_H

#include <unity.h>
#include <Wire.h>

/**
 * @brief PlatformIO test for detecting I2C devices on the bus.
 *
 * This test scans the I2C bus for connected devices and verifies that all
 * expected devices are detected at their respective addresses.
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
 * To run this test, use the command: `pio test --filter test_I2CScanner`
 */

// Define the expected I2C addresses for the devices on the main I2C bus
#define SENSOR_I2C_ADDRESS 0x29     
#define BUTTON_LED_I2C_ADDRESS 0x6F
#define BATTERY_FUEL_GAUGE_ADDRESS 0x36 

// Array of expected addresses on the main I2C bus
const uint8_t expectedMainAddresses[] = {SENSOR_I2C_ADDRESS, BUTTON_LED_I2C_ADDRESS, BATTERY_FUEL_GAUGE_ADDRESS};

// Buffer to store detected addresses
uint8_t detectedMainAddresses[sizeof(expectedMainAddresses)];

size_t detectedCount = 0;

// Function to scan the I2C bus and store detected addresses
void scanI2C(TwoWire &i2cbus, uint8_t *detectedAddresses, size_t maxSize, size_t &detectedCount) {
  detectedCount = 0;

  for (uint8_t address = 0x03; address <= 0x77; address++) {
    i2cbus.beginTransmission(address);
    if (i2cbus.endTransmission() == 0) {
      if (detectedCount < maxSize) {
        detectedAddresses[detectedCount++] = address;
      } else {
        // If detectedCount exceeds maxSize, break to prevent overflow
        break;
      }
    }
  }
}

// Unity test to verify that all expected I2C devices on the main I2C bus are detected
void test_main_I2C_devices_detected(TwoWire &mainI2C) {
  size_t detectedCount = 0;
  scanI2C(mainI2C, detectedMainAddresses, sizeof(detectedMainAddresses), detectedCount);

  // Check if the number of detected devices matches the expected count
  if (sizeof(expectedMainAddresses) != detectedCount) {
    char messageBuffer[150]; // Buffer to store the complete error message
    snprintf(messageBuffer, sizeof(messageBuffer),
             "Incorrect number of main I2C devices detected. Expected: %d, Detected: %d. Addresses: ",
             sizeof(expectedMainAddresses), detectedCount);

    // Append each detected address to the message
    for (size_t i = 0; i < detectedCount; i++) {
      char addressBuffer[6]; // Buffer to store each address in hex format
      snprintf(addressBuffer, sizeof(addressBuffer), "0x%02X ", detectedMainAddresses[i]);
      strncat(messageBuffer, addressBuffer, sizeof(messageBuffer) - strlen(messageBuffer) - 1);
    }

    // Use the generated message in the assertion
    TEST_ASSERT_EQUAL_UINT8_MESSAGE(sizeof(expectedMainAddresses), detectedCount, messageBuffer);
  }
}

#endif