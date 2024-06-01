#ifndef BLE_MODULE_H
#define BLE_MODULE_H

#include "../../include/DebugService.h"
#include <ArduinoBLE.h>

/**
 * @class BLEModule
 * @brief Represents a BLE (Bluetooth Low Energy) module.
 *
 * The BLEModule class provides a singleton instance of a BLE module. It allows
 * users to begin and end the BLE module, advertise the device, check if a
 * central device is connected, and retrieve the central device object.
 */
class BLEModule {
  public:
    /**
     * @brief Retrieves the singleton instance of the BLE module.
     * @return The singleton instance of the BLE module.
     */
    static BLEModule &getInstance() {
        static BLEModule instance;
        return instance;
    }

    /**
     * @brief Initializes the BLE module.
     * @return True if the BLE module starts successfully, false otherwise.
     */
    bool begin();

    /**
     * @brief Shuts down the BLE module.
     */
    void end();

    /**
     * @brief Starts advertising the device.
     */
    bool advertise();

  private:
    /**
     * @brief A reference to the DebugService singleton.
     *
     * This is used for debugging purposes.
     */
    DebugService &debugService = DebugService::getInstance();

    /**
     * @brief Private constructor to enforce singleton pattern.
     */
    BLEModule();

    // Prevent copying and assignment
    BLEModule(const BLEModule &) = delete;
    BLEModule &operator=(const BLEModule &) = delete;
};

#endif // BLE_MODULE_H