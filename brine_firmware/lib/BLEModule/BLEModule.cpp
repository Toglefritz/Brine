#include "BLEModule.h"
#include <WiFi.h>

BLEModule::BLEModule() {}

// The UUIDs of the primary service and the characteristic.
const char* PRIMARY_SERVICE_UUID = "6272696e-6573-616c-746d-6f6e69746f72";
const char* CHARACTERISTIC_UUID = "2f339202-178a-47ba-8a53-fa78187ab206";

/**
 * @brief Initializes the BLE module.
 * 
 * This function initializes the BLE module, sets up the primary service and its characteristic, and starts the BLE 
 * server. If the BLE module fails to start, an error message is printed and the function returns false.
 * 
 * @return True if the BLE module starts successfully, false otherwise.
 */
bool BLEModule::begin() {
    if (!BLE.begin()) {
        debugService.debugPrintln("Starting BLE module failed");
    
        return false;
    }

    // Create a new service
    BLEService primaryService = BLEService(PRIMARY_SERVICE_UUID);

    // Define the properties for the characteristic within the primary service
    uint8_t properties = BLERead | BLEWrite | BLENotify;    

    // Add a characteristic to the service
    BLECharacteristic primaryCharacteristic = BLECharacteristic(CHARACTERISTIC_UUID, properties, "");
    primaryService.addCharacteristic(primaryCharacteristic);

    // Add the service to the BLE server
    BLE.addService(primaryService);

    debugService.debugPrintln("BLE module started");

    return true;
}

/**
 * @brief Ends the BLE module.
 * 
 * This function calls the end() function of the BLE library to gracefully shut down the BLE module.
 * It should be called when you no longer need to use the BLE module.
 */
void BLEModule::end() {
    BLE.end();
}

/**
 * Starts advertising the BLE module.
 *
 * This function starts the advertisement process for the BLE module. It configures the advertisement settings and starts advertising.
 *
 * @return True if the advertisement was started successfully, false otherwise.
 */
bool BLEModule::advertise() {
    // Set the name of the device, which is the word "Brine" followed by the last 4 digits of the MAC address.
    String macAddress = WiFi.macAddress();
    String deviceName = "Brine " + macAddress.substring(9, 14);
    deviceName.replace(":", "");

    // Set the UUID of the primary service
    BLE.setAdvertisedServiceUuid(PRIMARY_SERVICE_UUID);

    BLE.setLocalName(deviceName.c_str());

    if(!BLE.advertise()) {
        debugService.debugPrintln("Starting advertisement failed");

        return false;
    }

    return true;
}