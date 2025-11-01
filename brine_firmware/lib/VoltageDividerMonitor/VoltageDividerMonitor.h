#ifndef VOLTAGE_DIVIDER_MONITOR_H
#define VOLTAGE_DIVIDER_MONITOR_H

#include <Arduino.h>

/**
 * VoltageDividerMonitor class provides battery monitoring functionality
 * using a voltage divider circuit connected to an ADC pin.
 * 
 * This class follows the same naming pattern as other sensor classes
 * in the firmware (e.g., VL53L0XSensor, VL53L1XSensor, MAX17048Monitor).
 */
class VoltageDividerMonitor {
public:
  /**
   * Constructor for voltage divider battery monitoring.
   * @param adcPin The analog pin connected to the voltage divider
   * @param r1 Resistor value closer to battery (in ohms, default 220k)
   * @param r2 Resistor value closer to ground (in ohms, default 100k)
   * @param maxVoltage The maximum battery voltage (e.g., 4.2V for LiPo)
   * @param minVoltage The minimum battery voltage (e.g., 3.0V for LiPo)
   */
  VoltageDividerMonitor(int adcPin = A0, 
                       float r1 = 220000.0, 
                       float r2 = 100000.0,
                       float maxVoltage = 4.2, 
                       float minVoltage = 3.0);

  /**
   * Initialize the voltage divider monitor.
   * @return true if initialization successful, false otherwise
   */
  bool begin();

  /**
   * Retrieves the battery life percentage from the voltage divider.
   *
   * @return The battery life percentage as a float value between 0 and 100.
   *         Returns -1.0 if the sensor is not available or failed to initialize.
   */
  float getBatteryLifePercent();

  /**
   * Get the raw battery voltage reading.
   * @return Battery voltage in volts
   */
  float getBatteryVoltage();

  /**
   * Check if the voltage divider monitor is available.
   * @return true if monitor is available, false otherwise
   */
  bool isAvailable() const;

private:
  int _adcPin;
  float _r1;              // Resistor closer to battery
  float _r2;              // Resistor closer to ground
  float _maxVoltage;
  float _minVoltage;
  float _voltageDividerRatio;
  bool _initialized;
  
  /**
   * Calculate the voltage divider ratio based on resistor values.
   */
  void calculateVoltageDividerRatio();
};

#endif // VOLTAGE_DIVIDER_MONITOR_H