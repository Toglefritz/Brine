#ifndef DISTANCE_SENSOR_H
#define DISTANCE_SENSOR_H

#include <SparkFun_VL53L1X.h>
#include <Wire.h>

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
   *
   * Returns true if the sensor was successfully initialized, and false
   * otherwise.
   */
  bool begin(TwoWire &i2cBus);

  /**
   * @brief Starts a distance measurement.
   *
   * Begins the process of ranging to determine distance.
   */
  void startMeasurement();

  /**
   * @brief Returnsn a range status indicating the operational status of the
   * sensor.
   *
   * @return The range status can be any of the following:
   *  - 0: No error
   *  - 1: Signal fail
   *  - 2: Sigma fail
   *  - 7: Wrapped target fail
   */
  int getRangeStatus();

  /**
   * @brief Gets the distance measurement data.
   *
   * Waits for the distance measurement to be ready, retrieves the data,
   * and stops ranging.
   *
   * @return The distance measured by the sensor in millimeters.
   */
  int getDistance();

  /**
   * @brief Stops the distance sensor.
   *
   * Halts any ongoing ranging operations and puts the sensor into an idle state.
   */
  void stopMeasurement();

private:
  SFEVL53L1X sensor; /// Instance of the sensor class.
};

#endif // VL53L1XService_h