#ifndef TEST_BATTERYMONITOR_H
#define TEST_BATTERYMONITOR_H

#include <unity.h>
#include <Wire.h>
#include <BatteryMonitor.h>

/*
 *  This test file tests the BatteryMonitor class. The BatteryMonitor class
 * provides functionality to monitor the battery level of an IoT device.
 * It utilizes the MAX17048 fuel gauge chip to calculate the remaining battery
 * life as a percentage. This test file verifies the functionality of the
 * BatteryMonitor class by checking if the battery life percentage is within
 * a reasonable range and that the MAX17048 initializes correctly.
 *
 *  Run this test with the command `pio test --filter test_BatteryMonitor`.
 */

/**
 * Checks that the battery monitor is able to obtain a battery level.
 */
void test_battery_life_percentage(TwoWire &mainI2C) {
  BatteryMonitor batteryMonitor = BatteryMonitor(mainI2C);

  // Test that the battery life percentage is within a reasonable range
  float batteryLife = batteryMonitor.getBatteryLifePercent();

  TEST_ASSERT_GREATER_OR_EQUAL(0.0, batteryLife); // Battery life should be 0% or more
  TEST_ASSERT_LESS_OR_EQUAL(100.0, batteryLife);  // Battery life should be 100% or less
}

#endif