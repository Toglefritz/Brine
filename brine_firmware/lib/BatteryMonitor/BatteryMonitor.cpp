#include "BatteryMonitor.h"
#include <SparkFun_MAX1704x_Fuel_Gauge_Arduino_Library.h>
#include <DebugService.h>

// Constructor
BatteryMonitor::BatteryMonitor() {
  // Initialize the MAX17048
  if (!_fuelGauge.begin()) {
    DebugService::getInstance().debugPrintln("MAX17048 initialization failed! Check wiring.");
  } else {
    DebugService::getInstance().debugPrintln("MAX17048 initialized successfully.");
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
 */
float BatteryMonitor::getBatteryLifePercent() {
  float batteryLife = _fuelGauge.getSOC(); // State of charge in percentage
  // Ensure the percentage is between 0 and 100
  batteryLife = constrain(batteryLife, 0, 100);

  DebugService::getInstance().debugPrint("Battery life: ");
  DebugService::getInstance().debugPrintln(String(batteryLife) + "%");

  return batteryLife;
}