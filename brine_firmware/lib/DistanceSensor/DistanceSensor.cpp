#include "DistanceSensor.h"
#include "DebugService.h" // For debugging output

// Constructor
DistanceSensor::DistanceSensor() : sensor() {}

/**
 * @brief Initializes the distance sensor.
 *
 * Begins I2C communication and checks the sensor's initial status.
 * The specific sensor type is determined by compile-time configuration.
 */
bool DistanceSensor::begin(TwoWire &i2cBus) {
#ifdef VL53L0X_SENSOR
  DebugService::getInstance().debugPrintln("Initializing VL53L0X distance sensor");
#else
  DebugService::getInstance().debugPrintln("Initializing VL53L1X distance sensor");
#endif
  
  return sensor.begin(i2cBus);
}

/**
 * @brief Starts the ranging process to measure distance.
 */
void DistanceSensor::startMeasurement() { 
  sensor.startMeasurement(); 
}

/**
 * @brief Retrieves the range status of the sensor.
 *
 * @return The range status can be any of the following:
 *  - 0: No error
 *  - 1: Signal fail
 *  - 2: Sigma fail
 *  - 7: Wrapped target fail
 */
int DistanceSensor::getRangeStatus() { 
  return sensor.getRangeStatus(); 
}

/**
 * @brief Retrieves the current distance measurement.
 *
 * Waits for the data to be ready, retrieves the measurement, and then
 * stops ranging. Logs the distance measurement for debugging purposes.
 *
 * @return Distance in millimeters as an integer.
 */
int DistanceSensor::getDistance() {
  return sensor.getDistance();
}

/**
 * @brief Stops the distance sensor from ranging.
 *
 * This function halts any ongoing distance measurements being performed
 * by the sensor. It ensures the sensor is put into an idle state, freeing
 * up the I2C bus for other devices.
 */
void DistanceSensor::stopMeasurement() {
  sensor.stopMeasurement();
}

/**
 * @brief Gets the sensor type being used.
 *
 * @return String indicating which sensor is active.
 */
String DistanceSensor::getSensorType() const {
#ifdef VL53L0X_SENSOR
  return "VL53L0X";
#else
  return "VL53L1X";
#endif
}