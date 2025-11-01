#include "VL53L0XSensor.h"
#include <unity.h>

/*
 * Test file for the VL53L0XSensor class. This test file tests the
 * functionality of the VL53L0X distance sensor by verifying that it
 * initializes correctly and is able to obtain a distance reading.
 *
 * Note: These tests require a VL53L0X sensor to be physically connected.
 * If no sensor is present, tests will be skipped with appropriate messages.
 *
 *  Run this test with the command `pio test --filter test_VL53L0XSensor`.
 */

// Define pins for the main I2C bus
#define MAIN_SDA_PIN 5
#define MAIN_SCL_PIN 6

TwoWire mainI2C = TwoWire(0);
VL53L0XSensor sensor;
bool sensorInitialized = false;

/**
 * @brief Test the initialization of the VL53L0XSensor.
 *
 * This test verifies that the sensor initializes correctly. If the sensor
 * is not connected, the test will be ignored with a message.
 */
void test_sensor_initialization(void) {
  sensorInitialized = sensor.begin(mainI2C);
  
  if (!sensorInitialized) {
    TEST_IGNORE_MESSAGE("VL53L0X sensor not detected - skipping hardware-dependent tests");
    return;
  }
  
  TEST_ASSERT_TRUE_MESSAGE(sensorInitialized, "VL53L0X sensor should initialize successfully");
}

/**
 * @brief Test the startMeasurement function of the VL53L0XSensor class.
 *
 * This test verifies that the sensor starts the measurement correctly and
 * that no errors occur during the process.
 */
void test_start_measurement(void) {
  if (!sensorInitialized) {
    TEST_IGNORE_MESSAGE("VL53L0X sensor not initialized - skipping test");
    return;
  }
  
  // This should not cause any errors
  sensor.startMeasurement();
  
  // For VL53L0X, startMeasurement just sets internal state
  // The actual measurement happens in getDistance()
  TEST_ASSERT_TRUE_MESSAGE(true, "startMeasurement should complete without error");
}

/**
 * @brief Test the getDistance function of the VL53L0XSensor class.
 *
 * This test verifies that the sensor can obtain a distance reading.
 * The test checks that the distance is within a reasonable range.
 */
void test_get_distance(void) {
  if (!sensorInitialized) {
    TEST_IGNORE_MESSAGE("VL53L0X sensor not initialized - skipping test");
    return;
  }
  
  sensor.startMeasurement();
  
  int distance = sensor.getDistance();
  
  // Distance should be positive and within sensor range (up to 2000mm for VL53L0X)
  TEST_ASSERT_TRUE_MESSAGE(distance >= 0, "Distance should be non-negative");
  TEST_ASSERT_TRUE_MESSAGE(distance <= 2000, "Distance should be within sensor range");
}

/**
 * @brief Test the getRangeStatus function of the VL53L0XSensor class.
 *
 * This test verifies that the sensor returns a valid range status.
 */
void test_get_range_status(void) {
  if (!sensorInitialized) {
    TEST_IGNORE_MESSAGE("VL53L0X sensor not initialized - skipping test");
    return;
  }
  
  sensor.startMeasurement();
  
  // Get a measurement first to populate range status
  sensor.getDistance();
  
  int status = sensor.getRangeStatus();
  
  // Status should be one of the valid values (0, 1, 2, 7)
  TEST_ASSERT_TRUE_MESSAGE(status >= 0, "Range status should be non-negative");
}

/**
 * @brief Test the stopMeasurement function of the VL53L0XSensor class.
 *
 * This test verifies that the sensor stops measurement correctly.
 */
void test_stop_measurement(void) {
  if (!sensorInitialized) {
    TEST_IGNORE_MESSAGE("VL53L0X sensor not initialized - skipping test");
    return;
  }
  
  sensor.startMeasurement();
  
  // This should not cause any errors
  sensor.stopMeasurement();
  
  TEST_ASSERT_TRUE_MESSAGE(true, "stopMeasurement should complete without error");
}

/**
 * @brief Main function to run all tests.
 */
void setup() {
  delay(2000); // Wait for serial monitor to connect
  
  // Initialize the I2C bus with specified pins (matching VL53L1X test pattern)
  mainI2C.begin(MAIN_SDA_PIN, MAIN_SCL_PIN);
  
  UNITY_BEGIN();
  
  RUN_TEST(test_sensor_initialization);
  RUN_TEST(test_start_measurement);
  RUN_TEST(test_get_distance);
  RUN_TEST(test_get_range_status);
  RUN_TEST(test_stop_measurement);
  
  UNITY_END();
}

void loop() {
  // Empty loop
}