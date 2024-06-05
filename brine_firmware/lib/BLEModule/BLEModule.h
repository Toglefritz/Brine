#ifndef BLE_MODULE_H
#define BLE_MODULE_H

#include "../../include/DebugService.h"

#include <BLE2902.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <WiFi.h>

// Define callback types
typedef std::function<void(BLEServer *pServer)> BLEConnectionCallback;
typedef std::function<void(BLEServer *pServer)> BLEDisconnectionCallback;
typedef std::function<void(BLECharacteristic *pCharacteristic)>
    BLEWriteCallback;
typedef std::function<void(BLECharacteristic *pCharacteristic)> BLEReadCallback;
typedef std::function<void(BLEDescriptor *pDescriptor)>
    BLEDescriptorWriteCallback;

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
     * @brief Retrieves an instance of the BLE module.
     */
    BLEModule();

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

    /**
     * @brief Sets the value of a BLE characteristic to a specified string
     * value.
     *
     * @param pCharacteristic A pointer to the BLECharacteristic object to be
     * updated.
     * @param value The string value to set for the characteristic.
     */
    void setCharacteristicValue(BLECharacteristic *pCharacteristic,
                                const std::string &value);

    /**
     * @brief  Set the connection callback. This callback is called when a
     * client device connects to the BLE server.
     * @param callback
     */
    void setConnectionCallback(BLEConnectionCallback callback);

    /**
     * @brief Set the disconnection callback. This callback is called when a
     * client device disconnects from the BLE server.
     * @param callback
     */
    void setDisconnectionCallback(BLEDisconnectionCallback callback);

    /**
     * @brief Set the write callback. This callback is called when a client
     * device writes to a BLE characteristic.
     * @param callback
     */
    void setWriteCallback(BLEWriteCallback callback);

    /**
     * @brief Set the read callback. This callback is called when a client
     * device reads from a BLE characteristic.
     * @param callback
     */
    void setReadCallback(BLEReadCallback callback);

    /**
     * @brief Set the descriptor write callback. This callback is called when a
     * client device writes to a BLE descriptor.
     * @param callback
     */
    void setDescriptorWriteCallback(BLEDescriptorWriteCallback callback);

  private:
    /**
     * @brief A reference to the DebugService singleton.
     *
     * This is used for debugging purposes.
     */
    DebugService &debugService = DebugService::getInstance();

    /**
     * @brief A pointer to the BLE server object.
    */
    BLEServer *pServer;

    BLEConnectionCallback connectionCallback; /**< The connection callback function. */
    BLEDisconnectionCallback disconnectionCallback; /**< The disconnection callback function. */
    BLEWriteCallback writeCallback; /**< The write callback function. */
    BLEReadCallback readCallback; /**< The read callback function. */
    BLEDescriptorWriteCallback descriptorWriteCallback; /**< The descriptor write callback function. */

    /**
     * @brief Retrieves the name of the device.
     *
     * This function retrieves the name of the device. The name is the word,
     * "Brine" followed by the last 4 digits of the MAC address of the device.
     *
     * @return The name of the device.
     */
    String getDeviceName();

    friend class ServerCallbacks;
    friend class Callbacks;
    friend class DescriptorCallbacks;
};

#endif // BLE_MODULE_H