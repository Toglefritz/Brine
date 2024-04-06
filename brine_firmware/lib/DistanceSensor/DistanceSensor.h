#ifndef DISTANCE_SENSOR_H
#define DISTANCE_SENSOR_H

#include <Wire.h>
#include "SparkFun_VL53L1X.h"
#include "DebugService.h"  // For debugging output

/**
 * @class DistanceSensor
 * @brief Provides services for interacting with the VL53L1X distance sensor.
 *
 * This class encapsulates functions for initializing the sensor, starting
 * a distance measurement, and retrieving the distance measurement data.
 */
class DistanceSensor {
public:
  /**
     * @brief Constructor for DistanceSensor.
     *
     * Initializes the sensor object.
     */
  DistanceSensor();

  /**
     * @brief Initializes the distance sensor.
     *
     * Sets up the sensor for operation, including beginning communication
     * over I2C and checking the sensor's initial status.
     */
  void init();

  /**
     * @brief Starts a distance measurement.
     *
     * Begins the process of ranging to determine distance.
     */
  void startMeasurement();

  /**
     * @brief Gets the distance measurement data.
     *
     * Waits for the distance measurement to be ready, retrieves the data,
     * and stops ranging.
     *
     * @return The distance measured by the sensor in millimeters.
     */
  int getDistance();

private:
  SFEVL53L1X sensor;  /// Instance of the sensor class.
};

#endif  // VL53L1XService_h