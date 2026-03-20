#include "VoltageDividerMonitor.h"
#include <DebugService.h>

// Constructor
VoltageDividerMonitor::VoltageDividerMonitor(int adcPin, float r1, float r2, float maxVoltage, float minVoltage) 
  : _adcPin(adcPin), _r1(r1), _r2(r2), _maxVoltage(maxVoltage), _minVoltage(minVoltage), _initialized(false) {
  calculateVoltageDividerRatio();
}

/**
 * Initialize the voltage divider monitor.
 * For voltage divider, this mainly involves setting up the ADC pin.
 */
bool VoltageDividerMonitor::begin() {
  // Set ADC resolution (ESP32 default is 12-bit)
  analogReadResolution(12);
  
  // Test read to verify ADC is working
  int testReading = analogRead(_adcPin);
  
  if (testReading >= 0 && testReading <= 4095) {
    _initialized = true;
    DebugService::getInstance().debugPrintln("Voltage divider monitor initialized successfully.");
    DebugService::getInstance().debugPrint("Voltage divider ratio: ");
    DebugService::getInstance().debugPrintln(String(_voltageDividerRatio));
    return true;
  } else {
    DebugService::getInstance().debugPrintln("Voltage divider monitor initialization failed!");
    return false;
  }
}

/**
 * Calculate the voltage divider ratio based on resistor values.
 * Vout = Vin * (R2 / (R1 + R2))
 * So Vin = Vout * ((R1 + R2) / R2)
 */
void VoltageDividerMonitor::calculateVoltageDividerRatio() {
  _voltageDividerRatio = (_r1 + _r2) / _r2;
}

/**
 * Get the raw battery voltage reading.
 */
float VoltageDividerMonitor::getBatteryVoltage() {
  if (!_initialized) {
    return -1.0;
  }
  
  // Read ADC value (12-bit: 0-4095)
  int adcValue = analogRead(_adcPin);
  
  // Convert ADC to voltage (ESP32 ADC reference is typically 3.3V)
  float adcVoltage = (adcValue / 4095.0) * 3.3;
  
  // Calculate actual battery voltage accounting for voltage divider
  float batteryVoltage = adcVoltage * _voltageDividerRatio;
  
  return batteryVoltage;
}

/**
 * Calculates and returns the battery life percentage using voltage divider.
 */
float VoltageDividerMonitor::getBatteryLifePercent() {
  if (!_initialized) {
    DebugService::getInstance().debugPrintln("Voltage divider not initialized, returning -1");
    return -1.0;
  }
  
  float batteryVoltage = getBatteryVoltage();
  
  if (batteryVoltage < 0) {
    return -1.0;
  }
  
  // Convert voltage to percentage using linear interpolation
  float batteryLife = ((batteryVoltage - _minVoltage) / (_maxVoltage - _minVoltage)) * 100.0;
  
  // Ensure the percentage is between 0 and 100
  batteryLife = constrain(batteryLife, 0, 100);
  
  DebugService::getInstance().debugPrint("Battery life (voltage divider): ");
  DebugService::getInstance().debugPrint(String(batteryVoltage, 2) + "V = ");
  DebugService::getInstance().debugPrintln(String(batteryLife, 1) + "%");
  
  return batteryLife;
}

/**
 * Check if the voltage divider monitor is available.
 */
bool VoltageDividerMonitor::isAvailable() const {
  return _initialized;
}