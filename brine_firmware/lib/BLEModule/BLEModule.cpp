#include "BLEModule.h"

BLEModule::BLEModule() {}

/**
 * @brief Initializes the BLE module.
 * 
 * This function initializes the BLE module and checks if it starts successfully.
 * If the BLE module fails to start, an error message is printed and the function returns false.
 * 
 * @return True if the BLE module starts successfully, false otherwise.
 */
bool BLEModule::begin() {
    if (!BLE.begin()) {
        debugService.debugPrintln("Starting BLE module failed");
    
        return false;
    }

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
    // TODO(Toglefritz): Add advertisement configuration

    if(!BLE.advertise()) {
        debugService.debugPrintln("Starting advertisement failed");

        return false;
    }

    return true;
}