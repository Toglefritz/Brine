#ifndef BATTERYMONITOR_H
#define BATTERYMONITOR_H

#include <Arduino.h>

/**
 * @class BatteryMonitor
 * @brief Manages battery level monitoring for IoT devices.
 *
 * This class provides functionality to monitor the battery level of an IoT device powered by three AA batteries in series. 
 * It utilizes a voltage divider circuit to safely measure the battery voltage without exceeding the maximum voltage rating of the sensing pin.
 * The class offers a simple interface to get the remaining battery life as a percentage, making it easy for other parts of the application to manage power consumption and battery life warnings.
 *
 * @note The voltage divider circuit must be designed with R1 = 10k Ohms and R2 = 4.7k Ohms to keep the voltage on the sensing pin (A0) below 3.3V.
 *
 * Example usage:
 * @code
 * BatteryMonitor batteryMonitor(A0); // Initialize with analog pin A0
 * float batteryLife = batteryMonitor.getBatteryLifePercent(); // Get battery life as a percentage
 * @endcode
 *
 * @param pin The analog pin number where the voltage divider output is connected.
 */
class BatteryMonitor {
public:
    /**
     * @brief Constructs a BatteryMonitor object.
     * @param pin The analog pin used to read the battery voltage.
     */
    BatteryMonitor(int pin);

    /**
     * @brief Gets the battery life percentage.
     * @return The battery life percentage as a float value.
     */
    float getBatteryLifePercent();

private:
    /**
     * @brief The analog pin used to read the battery voltage.
     */
    int _pin;

    /**
     * @brief Reads the battery voltage from the analog pin.
     * @return The battery voltage as a float value.
     */
    float readVoltage();
};

#endif // BATTERYMONITOR_H