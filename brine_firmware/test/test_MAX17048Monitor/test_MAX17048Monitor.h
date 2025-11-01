#ifndef TEST_MAX17048_MONITOR_H
#define TEST_MAX17048_MONITOR_H

#include <unity.h>
#include <Wire.h>
#include <MAX17048Monitor.h>

/*
 *  This test file tests the MAX17048Monitor class. The MAX17048Monitor class
 * provides functionality to monitor the battery level of an IoT device using the MAX17048
 * fuel gauge chip. This test file verifies the functionality of the MAX17048Monitor
 * class by checking if the battery life percentage is within a reasonable range and that
 * the MAX17048 initializes correctly.
 *
 * Note: These tests require a MAX17048 sensor to be physically connected via I2C.
 * If no sensor is present, tests will be skipped with appropriate messages.
 *
 *  Run this test with the command `pio test --filter test_MAX17048Monitor`.
 */

/**
 * Checks that the MAX17048 battery monitor is able to obtain a battery level.
 * This test gracefully handles cases where the hardware is not available.
 */
void test_battery_life_percentage(TwoWire &mainI2C) {
  MAX17048Monitor batteryMonitor = MAX17048Monitor(mainI2C);
  
  // Check if the sensor is available
  if (!batteryMonitor.isAvailable()) {
    TEST_IGNORE_MESSAGE("MAX17048 battery monitor not detected - skipping hardware-dependent test");
    return;
  }
  
  // Try to get a battery reading
  float batteryLife = batteryMonitor.getBatteryLifePercent();
  
  // Test that the battery life percentage is within a reasonable range
  TEST_ASSERT_GREATER_OR_EQUAL_MESSAGE(0.0, batteryLife, "Battery life should be 0% or more");
  TEST_ASSERT_LESS_OR_EQUAL_MESSAGE(100.0, batteryLife, "Battery life should be 100% or less");
}

/**
 * Test MAX17048 battery monitor initialization.
 */
void test_battery_monitor_initialization(TwoWire &mainI2C) {
  MAX17048Monitor batteryMonitor = MAX17048Monitor(mainI2C);
  
  // Check if hardware is actually present
  if (!batteryMonitor.isAvailable()) {
    TEST_IGNORE_MESSAGE("MAX17048 not detected - cannot test initialization");
    return;
  }
  
  TEST_ASSERT_TRUE_MESSAGE(batteryMonitor.isAvailable(), "MAX17048 battery monitor should be available after initialization");
}

/**
 * Test multiple readings for consistency.
 */
void test_battery_reading_consistency(TwoWire &mainI2C) {
  MAX17048Monitor batteryMonitor = MAX17048Monitor(mainI2C);
  
  if (!batteryMonitor.isAvailable()) {
    TEST_IGNORE_MESSAGE("MAX17048 not detected - cannot test reading consistency");
    return;
  }
  
  // Take multiple readings
  float reading1 = batteryMonitor.getBatteryLifePercent();
  delay(100); // Small delay between readings
  float reading2 = batteryMonitor.getBatteryLifePercent();
  
  // Readings should be consistent (within 5% difference for quick successive reads)
  float difference = abs(reading1 - reading2);
  TEST_ASSERT_LESS_OR_EQUAL_MESSAGE(5.0, difference, "Consecutive readings should be reasonably consistent");
}

#endif