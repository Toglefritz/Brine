#include "DistanceSensor.h"
#include <unity.h>

/*
 *  Test file for the DistanceSensor class. This test file tests the
 * functionality of the VLX53L1X distance sensor by verifying that it
 * initializes correctly and is able to obtain a distance reading.
 *
 *  Run this test with the command `pio test --filter test_DistanceSensor`.
 */

DistanceSensor sensor;

/**
 * @brief Test case for sensor initialization.
 *
 * This test verifies that the sensor initializes correctly.
 */
void test_sensor_initialization(void) {
    // Test that the sensor initializes correctly
    TEST_ASSERT_TRUE(sensor.begin());
}

/**
 * @brief Test the startMeasurement function of the DistanceSensor class.
 *
 * This test verifies that the sensor starts the measurement correctly and
 * obtains a valid range status.
 */
void test_start_measurement(void) {
    // Test that the sensor starts measurement correctly
    sensor.startMeasurement();
    // Check that the sensor obtained a valid measurement
    TEST_ASSERT(sensor.getRangeStatus() == 0);
}

/**
 * @brief Test case for the get_distance function.
 *
 * This test verifies that the distance sensor is able to correctly measure the
 * distance. It starts the measurement, gets the distance, and checks that the
 * distance is non-negative.
 */
void test_get_distance(void) {
    // Test that the sensor gets distance correctly
    // Start measurement before getting distance
    sensor.startMeasurement();
    int distance = sensor.getDistance();
    // Assuming that the sensor returns a non-negative distance
    TEST_ASSERT_GREATER_OR_EQUAL(0, distance);
}

/**
 * @brief Initializes the test suite and runs the test cases.
 *
 * This function is called once at the beginning of the test suite. It
 * initializes the Unity test framework and runs the test cases defined in the
 * suite.
 */
void setup() {
    // Join the I2C bus
    Wire.begin();
    
    UNITY_BEGIN();

    RUN_TEST(test_sensor_initialization);
    RUN_TEST(test_start_measurement);
    RUN_TEST(test_get_distance);

    UNITY_END();
}

void loop() {
    // No-op
}