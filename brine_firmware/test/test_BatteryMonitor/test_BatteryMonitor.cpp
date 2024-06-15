#include <BatteryMonitor.h>
#include <unity.h>

/*
 *  This test file tests the BatteryMonitor class. The BatteryMonitor class
 * provides functionality to monitor the battery level of an IoT device. It
 * utilizes a voltage divider circuit to measure the battery voltage and
 * calculates the remaining battery life as a percentage. This test file
 * verifies the functionality of the BatteryMonitor class by checking if the
 * battery life percentage is within a reasonable range when the device is
 * powered on.
 *
 *  Run this test with the command `pio test --filter test_BatteryMonitor`.
 */

void test_battery_monitor_initialization(void) {
    // Test that the BatteryMonitor initializes correctly
    BatteryMonitor batteryMonitor(A0); // Assuming A0 is the analog pin connected to the voltage divider
    TEST_ASSERT_NOT_EQUAL(-1, batteryMonitor.getBatteryLifePercent()); // Initialization should not result in -1 (error state)
}

void test_battery_life_percentage(void) {
    // Test that the battery life percentage is within a reasonable range
    BatteryMonitor batteryMonitor(A0);
    float batteryLife = batteryMonitor.getBatteryLifePercent();
    TEST_ASSERT_GREATER_OR_EQUAL(0.0, batteryLife); // Battery life should be 0% or more
    TEST_ASSERT_LESS_OR_EQUAL(100.0, batteryLife); // Battery life should be 100% or less
}

void setup() {
    UNITY_BEGIN(); // Start the Unity test framework
    RUN_TEST(test_battery_monitor_initialization);
    RUN_TEST(test_battery_life_percentage);
    UNITY_END(); // End the Unity test framework
}

void loop() {
    // Test environment runs setup() and then halts. loop() remains empty.
}