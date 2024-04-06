#include "DistanceSensor.h"
#include "DebugService.h"  // For debugging output

// Constructor
DistanceSensor::DistanceSensor() : sensor() {}

/**
 * @brief Initializes the VL53L1X sensor.
 *
 * Begins I2C communication and checks the sensor's initial status.
 * If initialization fails, it enters an infinite loop after logging the error.
 */
void DistanceSensor::init() {
    // Join the I2C bus
    Wire.begin();

    // Initialize the sensor
    int status = sensor.begin();

    // Check if the sensor failed to initialize
    if (status != 0) {
        DebugService::getInstance().debugPrint("Sensor failed to initialize with status ");
        DebugService::getInstance().debugPrintln(String(status));
        while (1); // Infinite loop on failure to initialize
        // TODO(Toglefritz): Handle error
    }
}

/**
 * @brief Starts the ranging process to measure distance.
 */
void DistanceSensor::startMeasurement() {
    sensor.startRanging();
}

/**
 * @brief Retrieves the current distance measurement.
 *
 * Waits for the data to be ready, retrieves the measurement, and then
 * stops ranging. Logs the distance measurement for debugging purposes.
 *
 * @return Distance in millimeters as an integer.
 */
int DistanceSensor::getDistance() {
    while (!sensor.checkForDataReady()) {
        delay(1); // Wait for measurement to be ready
    }
    int distance = sensor.getDistance();
    sensor.clearInterrupt();
    sensor.stopRanging();

    DebugService::getInstance().debugPrint("Sensor reading (mm): ");
    DebugService::getInstance().debugPrintln(String(distance));

    return distance;
}