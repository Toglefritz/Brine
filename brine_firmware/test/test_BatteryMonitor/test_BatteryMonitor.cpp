#include <Wire.h>
#include <unity.h>
#include "test_BatteryMonitor.h"

/*
 *  This test file tests the unified BatteryMonitor class. The BatteryMonitor class
 * provides a unified interface for battery monitoring that automatically adapts to
 * different hardware configurations based on build flags.
 * 
 * The tests gracefully handle cases where hardware is not available
 * by skipping hardware-dependent tests with appropriate messages.
 *
 *  Run this test with the command `pio test --filter test_BatteryMonitor`.
 */

// Global test variables
BatteryMonitor batteryMonitor;
bool monitorInitialized = false;

void setup() {
  delay(2000); // Wait for serial monitor to connect
  
#ifdef BATTERY_MONITOR_MAX17048
  // Initialize I2C for MAX17048 communication using pins from build configuration
  Wire.begin(I2C_SDA_PIN, I2C_SCL_PIN);
#endif

  // Start the Unity test framework
  UNITY_BEGIN();
  
  // Run all battery monitor tests
  RUN_TEST(test_battery_monitor_initialization);
  RUN_TEST(test_get_monitor_type);
  RUN_TEST(test_battery_life_percentage);
  RUN_TEST(test_battery_reading_consistency);
  
#ifndef BATTERY_MONITOR_MAX17048
  RUN_TEST(test_voltage_reading);
#endif

  // End the Unity test framework
  UNITY_END();
}

void loop() {
  // Test environment runs setup() and then halts. loop() remains empty.
}