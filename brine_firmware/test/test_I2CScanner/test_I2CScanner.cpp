#include <Arduino.h>
#include <Wire.h>
#include <unity.h>
#include "test_I2CScanner.h"

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

// Define pins for the main I2C bus
#define MAIN_SDA_PIN 21
#define MAIN_SCL_PIN 22

// The I2C interface for this test.
TwoWire mainI2C = TwoWire(0);

// Unity test to verify that all expected I2C devices on the main I2C bus are detected
void test_main_I2C_devices_detected(void) { test_main_I2C_devices_detected(mainI2C); }

void setup() {
  // Initialize the custom I2C instances with specified SDA and SCL pins
  mainI2C.begin(MAIN_SDA_PIN, MAIN_SCL_PIN);

  UNITY_BEGIN();                       // Start the Unity test framework
  RUN_TEST(test_main_I2C_devices_detected); // Run the I2C devices detection test
  UNITY_END();                         // End the Unity test framework
}

void loop() {
  // Empty loop for PlatformIO test runner
}