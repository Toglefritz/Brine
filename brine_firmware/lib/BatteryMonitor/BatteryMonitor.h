#ifndef BATTERY_MONITOR_H
#define BATTERY_MONITOR_H

#include <Wire.h>

// Conditional includes based on build configuration
#ifdef BATTERY_MONITOR_MAX17048
#include <MAX17048Monitor.h>
#else
#include <VoltageDividerMonitor.h>
#endif

/**
 * @class BatteryMonitor
 * @brief Unified interface for battery monitoring.
 *
 * This class provides a unified interface that can work with either
 * MAX17048 fuel gauge or voltage divider based on compile-time configuration.
 * Use -DBATTERY_MONITOR_MAX17048 build flag to use MAX17048, 
 * otherwise voltage divider is used.
 */
class BatteryMonitor {
public:
  /**
   * @brief Constructor for BatteryMonitor.
   *
   * Initializes the appropriate monitor object based on build configuration.
   */
  BatteryMonitor();

#ifdef BATTERY_MONITOR_MAX17048
  /**
   * @brief Constructor for MAX17048-based monitoring.
   * @param i2cBus Reference to the I2C bus for MAX17048 communication
   */
  BatteryMonitor(TwoWire &i2cBus);
#else
  /**
   * @brief Constructor for voltage divider-based monitoring.
   * @param adcPin The analog pin connected to the voltage divider
   * @param r1 Resistor value closer to battery (in ohms, default 220k)
   * @param r2 Resistor value closer to ground (in ohms, default 100k)
   * @param maxVoltage The maximum battery voltage (default 4.2V for LiPo)
   * @param minVoltage The minimum battery voltage (default 3.0V for LiPo)
   */
  BatteryMonitor(int adcPin, float r1 = 220000.0, float r2 = 100000.0, 
                float maxVoltage = 4.2, float minVoltage = 3.0);
#endif

  /**
   * @brief Initializes the battery monitor.
   *
   * Sets up the monitor for operation. For MAX17048, this includes I2C setup.
   * For voltage divider, this includes ADC configuration.
   *
   * @param i2cBus I2C bus reference (only used for MAX17048)
   * @return true if the monitor was successfully initialized, false otherwise
   */
  bool begin(TwoWire &i2cBus = Wire);

  /**
   * @brief Gets the battery life percentage.
   *
   * @return The battery life percentage as a float value between 0 and 100.
   *         Returns -1.0 if the monitor is not available.
   */
  float getBatteryLifePercent();

  /**
   * @brief Check if the battery monitor is available and responding.
   * @return true if monitor is available, false otherwise
   */
  bool isAvailable() const;

  /**
   * @brief Gets the monitor type being used.
   *
   * @return String indicating which monitor is active ("MAX17048" or "VoltageDivider").
   */
  String getMonitorType() const;

#ifndef BATTERY_MONITOR_MAX17048
  /**
   * @brief Get the raw battery voltage (only available for voltage divider).
   * @return Battery voltage in volts, or -1.0 if not available
   */
  float getBatteryVoltage();
#endif

private:
#ifdef BATTERY_MONITOR_MAX17048
  MAX17048Monitor monitor; /// Instance of the MAX17048 monitor class.
  TwoWire* _i2cBus;       /// Pointer to I2C bus for MAX17048
#else
  VoltageDividerMonitor monitor; /// Instance of the voltage divider monitor class.
#endif
};

#endif // BATTERY_MONITOR_H