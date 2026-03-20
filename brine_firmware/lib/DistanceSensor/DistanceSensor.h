#ifndef DISTANCE_SENSOR_H
#define DISTANCE_SENSOR_H

#include <Wire.h>

// Conditional includes based on build configuration
#ifdef VL53L0X_SENSOR
#include <VL53L0XSensor.h>
#else
#include <VL53L1XSensor.h>
#endif

/**
 * @class DistanceSensor
 * @brief Unified interface for distance sensors.
 *
 * This class provides a unified interface that can work with either
 * VL53L0X or VL53L1X sensors based on compile-time configuration.
 * Use -DVL53L0X_SENSOR build flag to use VL53L0X, otherwise VL53L1X is used.
 */
class DistanceSensor {
public:
  /**
   * @brief Constructor for DistanceSensor.
   *
   * Initializes the appropriate sensor object based on build configuration.
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
   * @brief Returns a range status indicating the operational status of the
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

  /**
   * @brief Gets the sensor type being used.
   *
   * @return String indicating which sensor is active ("VL53L0X" or "VL53L1X").
   */
  String getSensorType() const;

private:
#ifdef VL53L0X_SENSOR
  VL53L0XSensor sensor; /// Instance of the VL53L0X sensor class.
#else
  VL53L1XSensor sensor; /// Instance of the VL53L1X sensor class.
#endif
};

#endif // DISTANCE_SENSOR_H