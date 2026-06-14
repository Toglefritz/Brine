#include "VL53L1XSensor.h"
#include "DebugService.h" // For debugging output

// Constructor
VL53L1XSensor::VL53L1XSensor() : sensor(), lastRangeStatus(0) {}

/**
 * @brief Initializes the VL53L1X sensor.
 *
 * Begins I2C communication and checks the sensor's initial status.
 * If initialization fails, it enters an infinite loop after logging the error.
 */
bool VL53L1XSensor::begin(TwoWire &i2cBus) {
  // Initialize the sensor
  // SparkFun begin() returns true on success, false on failure
  bool status = sensor.begin(i2cBus);

  if (!status) {
    DebugService::getInstance().debugPrint("Sensor failed to initialize");
    DebugService::getInstance().debugPrintln("");

    return false;
  }

  return true;
}

/**
 * @brief Starts the ranging process to measure distance.
 */
void VL53L1XSensor::startMeasurement() { sensor.startRanging(); }

/**
 * @brief Retrieves the range status of the sensor.
 *
 * @return The range status can be any of the following:
 *  - 0: No error
 *  - 1: Signal fail
 *  - 2: Sigma fail
 *  - 7: Wrapped target fail
 */
int VL53L1XSensor::getRangeStatus() { return lastRangeStatus; }

/**
 * @brief Retrieves the current distance measurement.
 *
 * Waits for the data to be ready, retrieves the measurement, and then
 * stops ranging. Logs the distance measurement for debugging purposes.
 *
 * @return Distance in millimeters as an integer.
 */
int VL53L1XSensor::getDistance() {
  while (!sensor.checkForDataReady()) {
    delay(1); // Wait for measurement to be ready
  }
  int distance = sensor.getDistance();
  lastRangeStatus = sensor.getRangeStatus(); // Cache before clearing
  sensor.clearInterrupt();
  sensor.stopRanging();

  DebugService::getInstance().debugPrint("Sensor reading (mm): ");
  DebugService::getInstance().debugPrintln(String(distance));

  return distance;
}

/**
 * @brief Stops the VL53L1X distance sensor from ranging.
 *
 * This function halts any ongoing distance measurements being performed
 * by the sensor. It ensures the sensor is put into an idle state, freeing
 * up the I2C bus for other devices. This is especially important to
 * prevent I2C conflicts or unnecessary power consumption when the sensor
 * is not actively being used.
 *
 * This method should be called after retrieving the distance measurement
 * to ensure the sensor does not interfere with other I2C operations.
 */
void VL53L1XSensor::stopMeasurement() {
  DebugService::getInstance().debugPrint("Stopping distance sensor");
  sensor.stopRanging(); // Safely stop the sensor
}