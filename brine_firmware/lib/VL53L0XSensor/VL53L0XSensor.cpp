#include "VL53L0XSensor.h"
#include "DebugService.h" // For debugging output

// Constructor
VL53L0XSensor::VL53L0XSensor() : sensor(), measurementActive(false), lastRangeStatus(0) {}

/**
 * @brief Initializes the VL53L0X sensor.
 *
 * Begins I2C communication and checks the sensor's initial status.
 * If initialization fails, it logs the error and returns false.
 */
bool VL53L0XSensor::begin(TwoWire &i2cBus) {
  DebugService::getInstance().debugPrintln("Attempting to initialize VL53L0X sensor...");
  
  // Initialize the sensor with timeout protection
  bool status = false;
  
  try {
    status = sensor.begin(VL53L0X_I2C_ADDR, false, &i2cBus);
  } catch (...) {
    DebugService::getInstance().debugPrintln("Exception during VL53L0X initialization");
    return false;
  }

  // Check if the sensor failed to initialize
  if (!status) {
    DebugService::getInstance().debugPrintln("VL53L0X sensor failed to initialize - sensor may not be connected");
    return false;
  } else {
    DebugService::getInstance().debugPrintln("VL53L0X sensor initialized successfully");
    return true;
  }
}

/**
 * @brief Starts the ranging process to measure distance.
 */
void VL53L0XSensor::startMeasurement() { 
  measurementActive = true;
  // VL53L0X doesn't have a separate start ranging method like VL53L1X
  // The measurement is started when we call readRange()
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
int VL53L0XSensor::getRangeStatus() { 
  return lastRangeStatus; 
}

/**
 * @brief Retrieves the current distance measurement.
 *
 * Performs a single range measurement and retrieves the data.
 * Logs the distance measurement for debugging purposes.
 *
 * @return Distance in millimeters as an integer.
 */
int VL53L0XSensor::getDistance() {
  VL53L0X_RangingMeasurementData_t measure;
  
  DebugService::getInstance().debugPrintln("Performing VL53L0X measurement...");
  
  // Perform the measurement with error handling
  try {
    sensor.rangingTest(&measure, false);
  } catch (...) {
    DebugService::getInstance().debugPrintln("Exception during VL53L0X measurement");
    lastRangeStatus = 2; // Sigma fail
    measurementActive = false;
    return -1; // Return error value
  }
  
  // Store the range status for getRangeStatus() calls
  lastRangeStatus = measure.RangeStatus;
  
  int distance = measure.RangeMilliMeter;
  
  // Map VL53L0X status codes to match VL53L1X interface
  // VL53L0X uses different status codes, so we map them
  if (measure.RangeStatus == 4) {
    // Phase failures -> map to signal fail
    lastRangeStatus = 1;
  } else if (measure.RangeStatus != 0) {
    // Other failures -> map to sigma fail
    lastRangeStatus = 2;
  } else {
    lastRangeStatus = 0; // No error
  }

  DebugService::getInstance().debugPrint("VL53L0X reading (mm): ");
  DebugService::getInstance().debugPrint(String(distance));
  DebugService::getInstance().debugPrint(", status: ");
  DebugService::getInstance().debugPrintln(String(lastRangeStatus));
  
  measurementActive = false;
  return distance;
}

/**
 * @brief Stops the VL53L0X distance sensor from ranging.
 *
 * This function halts any ongoing distance measurements being performed
 * by the sensor. For VL53L0X, this simply marks measurement as inactive
 * since each measurement is a single shot operation.
 */
void VL53L0XSensor::stopMeasurement() {
  DebugService::getInstance().debugPrint("Stopping VL53L0X distance sensor");
  measurementActive = false;
}