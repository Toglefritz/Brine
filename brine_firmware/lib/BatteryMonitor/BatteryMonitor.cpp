#include "BatteryMonitor.h"

// Constructor
BatteryMonitor::BatteryMonitor(int pin) : _pin(pin) {
    pinMode(_pin, INPUT);
}

/**
 * Reads the voltage from the battery monitor sensor.
 * 
 * @return The voltage value in volts.
 */
float BatteryMonitor::readVoltage() {
    int sensorValue = analogRead(_pin);
    // Convert the analog reading (which goes from 0 - 1023) to a voltage (0 - 4.8V)
    float voltage = sensorValue * (4.8 / 1023.0); 
    
    return voltage;
}

/**
 * Calculates and returns the battery life percentage.
 *
 * This function calculates the battery life percentage based on the current voltage reading
 * and the maximum and minimum voltage values. The maximum voltage is set to 4.8 volts, which
 * represents the maximum voltage of 3 AA batteries in series. The minimum voltage is set to
 * 3.6 volts, which is considered the voltage before the batteries are considered dead (1.2V
 * per battery).
 *
 * @return The battery life percentage as a float value between 0 and 100.
 */
float BatteryMonitor::getBatteryLifePercent() {
    float voltage = readVoltage();

    // Maximum voltage of 3 AA batteries in series
    float maxVoltage = 4.8; 
    // Minimum voltage before considered dead (1.2V per battery)
    float minVoltage = 3.6;

    // Calculate the battery life percentage
    float batteryLife = (voltage - minVoltage) / (maxVoltage - minVoltage) * 100;
    // Ensure the percentage is between 0 and 100
    batteryLife = constrain(batteryLife, 0, 100);
    
    return batteryLife;
}