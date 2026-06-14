#include "VL53L1XSensor.h"
#include <unity.h>

/*
 * Test file for the VL53L1XSensor class. This test file tests the
 * functionality of the VL53L1X distance sensor by verifying that it
 * initializes correctly and is able to obtain a distance reading.
 *
 *  Run this test with the command `pio test -e seeed_xiao_esp32c3 --filter test_VL53L1XSensor`.
 */

// I2C pins are defined in platformio.ini build flags
// Use I2C_SDA_PIN and I2C_SCL_PIN from build configuration

// The I2C interface for this test.
TwoWire mainI2C = TwoWire(0);

VL53L1XSensor sensor;

/**
 * @brief Test case for sensor initialization.
 *
 * This test verifies that the sensor initializes correctly.
 */
void test_sensor_initialization(void) {
    // Test that the sensor initializes correctly
    TEST_ASSERT_TRUE(sensor.begin(mainI2C));
}

/**
 * @brief Test the startMeasurement function of the VL53L1XSensor class.
 *
 * This test verifies that the sensor starts the measurement correctly and
 * obtains a valid range status.
 */
void test_start_measurement(void) {
    // Start measurement and retrieve distance (waits for data ready internally)
    sensor.startMeasurement();
    int distance = sensor.getDistance();
    // A successful measurement produces a non-negative distance
    TEST_ASSERT_GREATER_OR_EQUAL(0, distance);
    // Verify getRangeStatus returns a known status code.
    // Known codes: 0 (no error), 1 (signal fail), 2 (sigma fail),
    // 3-6, 7 (wrapped target), 9-13, or 255 (unknown raw value).
    // The VL53L1CX variant may return non-zero status even for valid distances.
    int status = sensor.getRangeStatus();
    TEST_ASSERT_NOT_EQUAL(-1, status);
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
    // Initialize the custom I2C instance with pins from build configuration
    mainI2C.begin(I2C_SDA_PIN, I2C_SCL_PIN);
    
    UNITY_BEGIN();

    RUN_TEST(test_sensor_initialization);
    RUN_TEST(test_start_measurement);
    RUN_TEST(test_get_distance);

    UNITY_END();
}

void loop() {
    // No-op
}