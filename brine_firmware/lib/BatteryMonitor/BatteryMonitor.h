#ifndef BATTERY_MONITOR_H
#define BATTERY_MONITOR_H

#include <SparkFun_MAX1704x_Fuel_Gauge_Arduino_Library.h>

class BatteryMonitor {
public:
  /**
   * Constructor initializes the MAX17048 fuel gauge.
   */
  BatteryMonitor();

  /**
   * Retrieves the battery life percentage from the MAX17048.
   *
   * @return The battery life percentage as a float value between 0 and 100.
   */
  float getBatteryLifePercent();

private:
  SFE_MAX1704X _fuelGauge; // MAX17048 Fuel Gauge object
};

#endif // BATTERY_MONITOR_H