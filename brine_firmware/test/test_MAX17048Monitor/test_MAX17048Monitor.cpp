#include <Wire.h>
#include <unity.h>
#include "test_MAX17048Monitor.h"

/*
 *  This test file tests the MAX17048Monitor class. The MAX17048Monitor class
 * provides functionality to monitor the battery level of an IoT device using the MAX17048
 * fuel gauge chip via I2C communication.
 * 
 * The tests gracefully handle cases where the MAX17048 hardware is not available
 * by skipping hardware-dependent tests with appropriate messages.
 *
 *  Run this test with the command `pio test -e seeed_xiao_esp32c3 --filter test_MAX17048Monitor`.
 */

// I2C pins are defined in platformio.ini build flags
// Use I2C_SDA_PIN and I2C_SCL_PIN from build configuration

// The I2C interface for this test.
TwoWire mainI2C = TwoWire(0);

/**
 * Test wrapper for battery life percentage reading.
 */
void test_battery_life_percentage_wrapper(void) { 
  test_battery_life_percentage(mainI2C); 
}

/**
 * Test wrapper for battery monitor initialization.
 */
void test_battery_monitor_initialization_wrapper(void) { 
  test_battery_monitor_initialization(mainI2C); 
}

/**
 * Test wrapper for battery reading consistency.
 */
void test_battery_reading_consistency_wrapper(void) { 
  test_battery_reading_consistency(mainI2C); 
}

void setup() {
  delay(2000); // Wait for serial monitor to connect
  
  // Initialize I2C for MAX17048 communication using pins from build configuration
  mainI2C.begin(I2C_SDA_PIN, I2C_SCL_PIN);

  // Start the Unity test framework
  UNITY_BEGIN();
  
  // Run all MAX17048 battery monitor tests
  RUN_TEST(test_battery_monitor_initialization_wrapper);
  RUN_TEST(test_battery_life_percentage_wrapper);
  RUN_TEST(test_battery_reading_consistency_wrapper);

  // End the Unity test framework
  UNITY_END();
}

void loop() {
  // Test environment runs setup() and then halts. loop() remains empty.
}