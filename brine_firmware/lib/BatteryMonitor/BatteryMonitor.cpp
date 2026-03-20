#include "BatteryMonitor.h"
#include "DebugService.h"

// Default constructor
BatteryMonitor::BatteryMonitor() 
#ifdef BATTERY_MONITOR_MAX17048
  : monitor(Wire), _i2cBus(&Wire) 
#else
  : monitor() // Use default voltage divider parameters
#endif
{
}

#ifdef BATTERY_MONITOR_MAX17048
// Constructor for MAX17048
BatteryMonitor::BatteryMonitor(TwoWire &i2cBus) 
  : monitor(i2cBus), _i2cBus(&i2cBus) {
}
#else
// Constructor for voltage divider
BatteryMonitor::BatteryMonitor(int adcPin, float r1, float r2, float maxVoltage, float minVoltage) 
  : monitor(adcPin, r1, r2, maxVoltage, minVoltage) {
}
#endif

/**
 * @brief Initializes the battery monitor.
 *
 * The specific monitor type is determined by compile-time configuration.
 */
bool BatteryMonitor::begin(TwoWire &i2cBus) {
#ifdef BATTERY_MONITOR_MAX17048
  DebugService::getInstance().debugPrintln("Initializing MAX17048 battery monitor");
  _i2cBus = &i2cBus;
  // Create new MAX17048Monitor instance with the correct I2C bus
  monitor = MAX17048Monitor(i2cBus);
  return monitor.isAvailable();
#else
  DebugService::getInstance().debugPrintln("Initializing voltage divider battery monitor");
  return monitor.begin();
#endif
}

/**
 * @brief Gets the battery life percentage.
 */
float BatteryMonitor::getBatteryLifePercent() {
  return monitor.getBatteryLifePercent();
}

/**
 * @brief Check if the battery monitor is available.
 */
bool BatteryMonitor::isAvailable() const {
  return monitor.isAvailable();
}

/**
 * @brief Gets the monitor type being used.
 */
String BatteryMonitor::getMonitorType() const {
#ifdef BATTERY_MONITOR_MAX17048
  return "MAX17048";
#else
  return "VoltageDivider";
#endif
}

#ifndef BATTERY_MONITOR_MAX17048
/**
 * @brief Get the raw battery voltage (voltage divider only).
 */
float BatteryMonitor::getBatteryVoltage() {
  return monitor.getBatteryVoltage();
}
#endif