#include "MAX17048Monitor.h"
#include <DebugService.h>

// Constructor
MAX17048Monitor::MAX17048Monitor(TwoWire &i2cBus) : _sensorAvailable(false) {
  // Initialize the MAX17048
  if (_fuelGauge.begin(i2cBus)) {
    _sensorAvailable = true;
    DebugService::getInstance().debugPrintln("MAX17048 initialized successfully.");
  } else {
    DebugService::getInstance().debugPrintln("MAX17048 initialization failed! Check wiring.");
  }
}

/**
 * Calculates and returns the battery life percentage using the MAX17048.
 *
 * This function directly retrieves the battery life percentage from the MAX17048
 * fuel gauge chip, which internally calculates the remaining capacity of the
 * LiPo battery.
 *
 * @return The battery life percentage as a float value between 0 and 100.
 *         Returns -1.0 if the sensor is not available.
 */
float MAX17048Monitor::getBatteryLifePercent() {
  if (!_sensorAvailable) {
    DebugService::getInstance().debugPrintln("MAX17048 not available, returning -1");
    return -1.0;
  }

  float batteryLife = _fuelGauge.getSOC(); // State of charge in percentage
  // Ensure the percentage is between 0 and 100
  batteryLife = constrain(batteryLife, 0, 100);

  DebugService::getInstance().debugPrint("Battery life (MAX17048): ");
  DebugService::getInstance().debugPrintln(String(batteryLife) + "%");

  return batteryLife;
}

/**
 * Check if the MAX17048 sensor is available and responding.
 * @return true if sensor is available, false otherwise
 */
bool MAX17048Monitor::isAvailable() const {
  return _sensorAvailable;
}