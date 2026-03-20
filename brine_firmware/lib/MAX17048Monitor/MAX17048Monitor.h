#ifndef MAX17048_MONITOR_H
#define MAX17048_MONITOR_H

#include <SparkFun_MAX1704x_Fuel_Gauge_Arduino_Library.h>
#include <Wire.h>

/**
 * MAX17048Monitor class provides battery monitoring functionality
 * using the MAX17048 fuel gauge chip via I2C communication.
 * 
 * This class follows the same naming pattern as other sensor classes
 * in the firmware (e.g., VL53L0XSensor, VL53L1XSensor).
 */
class MAX17048Monitor {
public:
  /**
   * Constructor initializes the MAX17048 fuel gauge.
   * @param i2cBus Reference to the I2C bus for communication
   */
  MAX17048Monitor(TwoWire &i2cBus);

  /**
   * Retrieves the battery life percentage from the MAX17048.
   *
   * @return The battery life percentage as a float value between 0 and 100.
   *         Returns -1.0 if the sensor is not available or failed to initialize.
   */
  float getBatteryLifePercent();

  /**
   * Check if the MAX17048 sensor is available and responding.
   * @return true if sensor is available, false otherwise
   */
  bool isAvailable() const;

private:
  SFE_MAX1704X _fuelGauge; // MAX17048 Fuel Gauge object
  bool _sensorAvailable;   // Track if sensor initialized successfully
};

#endif // MAX17048_MONITOR_H