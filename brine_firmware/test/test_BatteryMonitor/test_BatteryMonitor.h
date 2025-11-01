#ifndef TEST_BATTERY_MONITOR_H
#define TEST_BATTERY_MONITOR_H

#include <unity.h>
#include <Wire.h>
#include <BatteryMonitor.h>

/*
 *  This test file tests the unified BatteryMonitor class. The BatteryMonitor class
 * provides a unified interface for battery monitoring that works with different
 * hardware configurations:
 * - MAX17048 fuel gauge chip (I2C-based, high accuracy)
 * - Voltage divider (ADC-based, simple implementation)
 * 
 * The tests automatically adapt to the hardware configuration specified
 * in build flags and gracefully skip tests when hardware is not available.
 *
 *  Run this test with the command `pio test --filter test_BatteryMonitor`.
 */

// Global variables for test state
extern BatteryMonitor batteryMonitor;
extern bool monitorInitialized;

/**
 * Test battery monitor initialization.
 */
void test_battery_monitor_initialization(void) {
  // Initialize the monitor (I2C parameter only used for MAX17048)
  monitorInitialized = batteryMonitor.begin(Wire);
  
  if (!monitorInitialized) {
    String monitorType = batteryMonitor.getMonitorType();
#ifdef BATTERY_MONITOR_MAX17048
    TEST_IGNORE_MESSAGE("MAX17048 battery monitor not detected - skipping hardware-dependent tests");
#else
    TEST_IGNORE_MESSAGE("Voltage divider battery monitor not detected - skipping hardware-dependent tests");
#endif
    return;
  }
  
  TEST_ASSERT_TRUE_MESSAGE(batteryMonitor.isAvailable(), "Battery monitor should be available after initialization");
}

/**
 * Test monitor type reporting.
 */
void test_get_monitor_type(void) {
  String monitorType = batteryMonitor.getMonitorType();
  
#ifdef BATTERY_MONITOR_MAX17048
  TEST_ASSERT_EQUAL_STRING_MESSAGE("MAX17048", monitorType.c_str(), "Should report MAX17048 monitor type");
#else
  TEST_ASSERT_EQUAL_STRING_MESSAGE("VoltageDivider", monitorType.c_str(), "Should report VoltageDivider monitor type");
#endif
}

/**
 * Checks that the battery monitor is able to obtain a battery level.
 * This test adapts to different hardware configurations based on build flags.
 */
void test_battery_life_percentage(void) {
  if (!monitorInitialized) {
    TEST_IGNORE_MESSAGE("Battery monitor not initialized - skipping test");
    return;
  }
  
  // Try to get a battery reading
  float batteryLife = batteryMonitor.getBatteryLifePercent();
  
  // Test that the battery life percentage is within a reasonable range
  TEST_ASSERT_GREATER_OR_EQUAL_MESSAGE(0.0, batteryLife, "Battery life should be 0% or more");
  TEST_ASSERT_LESS_OR_EQUAL_MESSAGE(100.0, batteryLife, "Battery life should be 100% or less");
}

/**
 * Test multiple readings for consistency.
 */
void test_battery_reading_consistency(void) {
  if (!monitorInitialized) {
    TEST_IGNORE_MESSAGE("Battery monitor not initialized - skipping test");
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

#ifndef BATTERY_MONITOR_MAX17048
/**
 * Test voltage reading (voltage divider only).
 */
void test_voltage_reading(void) {
  if (!monitorInitialized) {
    TEST_IGNORE_MESSAGE("Voltage divider not initialized - skipping test");
    return;
  }
  
  float voltage = batteryMonitor.getBatteryVoltage();
  
  // Voltage should be reasonable for a LiPo battery (2.5V to 4.5V range)
  TEST_ASSERT_GREATER_OR_EQUAL_MESSAGE(2.5, voltage, "Battery voltage should be at least 2.5V");
  TEST_ASSERT_LESS_OR_EQUAL_MESSAGE(4.5, voltage, "Battery voltage should be at most 4.5V");
}
#endif

#endif