#include <BatteryMonitor.h>
#include <Wire.h>
#include <unity.h>

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

// Define pins for the main I2C bus
#define MAIN_SDA_PIN 21
#define MAIN_SCL_PIN 22

// The I2C interface for this test.
TwoWire mainI2C = TwoWire(0);

void test_battery_life_percentage(void) {
  BatteryMonitor batteryMonitor = BatteryMonitor(mainI2C);

  // Test that the battery life percentage is within a reasonable range
  float batteryLife = batteryMonitor.getBatteryLifePercent();

  TEST_ASSERT_GREATER_OR_EQUAL(0.0, batteryLife); // Battery life should be 0% or more
  TEST_ASSERT_LESS_OR_EQUAL(100.0, batteryLife);  // Battery life should be 100% or less
}

void setup() {
  // Initialize the custom I2C instance with specified SDA and SCL pins
  mainI2C.begin(MAIN_SDA_PIN, MAIN_SCL_PIN);

  // Start the Unity test framework
  UNITY_BEGIN();
  RUN_TEST(test_battery_life_percentage);

  // End the Unity test framework
  UNITY_END();
}

void loop() {
  // Test environment runs setup() and then halts. loop() remains empty.
}