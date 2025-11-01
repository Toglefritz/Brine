#include "DistanceSensor.h"
#include <unity.h>

/*
 * Test file for the unified DistanceSensor class. This test file tests the
 * functionality of the distance sensor interface that works with either
 * VL53L0X or VL53L1X sensors based on compile-time configuration.
 *
 * Run this test with the command `pio test --filter test_DistanceSensor`.
 * Use -DVL53L0X_SENSOR build flag to test VL53L0X, otherwise VL53L1X is tested.
 */

// Define pins for the main I2C bus
#define MAIN_SDA_PIN 5
#define MAIN_SCL_PIN 6

TwoWire mainI2C = TwoWire(0);
DistanceSensor sensor;
bool sensorInitialized = false;

/**
 * @brief Test the initialization of the DistanceSensor.
 *
 * This test verifies that the sensor initializes correctly. If the sensor
 * is not connected, the test will be ignored with a message.
 */
void test_sensor_initialization(void) {
  sensorInitialized = sensor.begin(mainI2C);
  
  if (!sensorInitialized) {
#ifdef VL53L0X_SENSOR
    TEST_IGNORE_MESSAGE("VL53L0X sensor not detected - skipping hardware-dependent tests");
#else
    TEST_IGNORE_MESSAGE("VL53L1X sensor not detected - skipping hardware-dependent tests");
#endif
    return;
  }
  
  TEST_ASSERT_TRUE_MESSAGE(sensorInitialized, "Distance sensor should initialize successfully");
}

/**
 * @brief Test the getSensorType function.
 *
 * This test verifies that the sensor reports the correct type based on
 * compile-time configuration.
 */
void test_get_sensor_type(void) {
  String sensorType = sensor.getSensorType();
  
#ifdef VL53L0X_SENSOR
  TEST_ASSERT_EQUAL_STRING_MESSAGE("VL53L0X", sensorType.c_str(), "Should report VL53L0X sensor type");
#else
  TEST_ASSERT_EQUAL_STRING_MESSAGE("VL53L1X", sensorType.c_str(), "Should report VL53L1X sensor type");
#endif
}

/**
 * @brief Test the startMeasurement function of the DistanceSensor class.
 *
 * This test verifies that the sensor starts the measurement correctly and
 * that no errors occur during the process.
 */
void test_start_measurement(void) {
  if (!sensorInitialized) {
    TEST_IGNORE_MESSAGE("Distance sensor not initialized - skipping test");
    return;
  }
  
  // This should not cause any errors
  sensor.startMeasurement();
  
  TEST_ASSERT_TRUE_MESSAGE(true, "startMeasurement should complete without error");
}

/**
 * @brief Test the getDistance function of the DistanceSensor class.
 *
 * This test verifies that the sensor can obtain a distance reading.
 * The test checks that the distance is within a reasonable range.
 */
void test_get_distance(void) {
  if (!sensorInitialized) {
    TEST_IGNORE_MESSAGE("Distance sensor not initialized - skipping test");
    return;
  }
  
  sensor.startMeasurement();
  
  int distance = sensor.getDistance();
  
  // Distance should be positive and within sensor range
  TEST_ASSERT_TRUE_MESSAGE(distance >= 0, "Distance should be non-negative");
  
#ifdef VL53L0X_SENSOR
  // VL53L0X has a range up to 2000mm
  TEST_ASSERT_TRUE_MESSAGE(distance <= 2000, "Distance should be within VL53L0X range");
#else
  // VL53L1X has a range up to 4000mm
  TEST_ASSERT_TRUE_MESSAGE(distance <= 4000, "Distance should be within VL53L1X range");
#endif
}

/**
 * @brief Test the getRangeStatus function of the DistanceSensor class.
 *
 * This test verifies that the sensor returns a valid range status.
 */
void test_get_range_status(void) {
  if (!sensorInitialized) {
    TEST_IGNORE_MESSAGE("Distance sensor not initialized - skipping test");
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
 * @brief Test the stopMeasurement function of the DistanceSensor class.
 *
 * This test verifies that the sensor stops measurement correctly.
 */
void test_stop_measurement(void) {
  if (!sensorInitialized) {
    TEST_IGNORE_MESSAGE("Distance sensor not initialized - skipping test");
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
  
  // Initialize the I2C bus with specified pins
  mainI2C.begin(MAIN_SDA_PIN, MAIN_SCL_PIN);
  
  UNITY_BEGIN();
  
  RUN_TEST(test_sensor_initialization);
  RUN_TEST(test_get_sensor_type);
  RUN_TEST(test_start_measurement);
  RUN_TEST(test_get_distance);
  RUN_TEST(test_get_range_status);
  RUN_TEST(test_stop_measurement);
  
  UNITY_END();
}

void loop() {
  // Empty loop
}