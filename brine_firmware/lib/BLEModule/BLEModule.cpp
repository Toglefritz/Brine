#include "BLEModule.h"

BLEModule::BLEModule() {}

// The BLE server used by the Brine module to communicate with the central device, which
// is typically the Brine app.
BLEServer *pServer;

// The UUIDs of the primary service and the characteristic.
const char *PRIMARY_SERVICE_UUID = "6272696e-6573-616c-746d-6f6e69746f72";
const char *CHARACTERISTIC_UUID = "2f339202-178a-47ba-8a53-fa78187ab206";

 /**
 * @brief Retrieves the name of the device.
 * 
 * This function retrieves the name of the device. The name is the word, "Brine" 
 * followed by the last 4 digits of the MAC address of the device.
 * 
 * @return The name of the device.
 */
String BLEModule::getDeviceName() {
    // Set the name of the device, which is the word "Brine" followed by the
    // last 4 digits of the MAC address.
    String macAddress = WiFi.macAddress();
    String deviceName = "Brine " + macAddress.substring(9, 14);
    deviceName.replace(":", "");

    return deviceName;
}

/**
 * @class ServerCallbacks
 * @brief A class to handle BLE server connection and disconnection events.
 *
 * This class extends the BLEServerCallbacks class and overrides its methods
 * to provide custom behavior for when a client connects and disconnects from the
 * BLE server.
 *
 * @method onConnect
 * This method is called when a client device connects to the BLE server.
 *
 * @method onDisconnect
 * This method is called when a client device disconnects from the BLE server.
 */
class ServerCallbacks : public BLEServerCallbacks {
public:
    ServerCallbacks(BLEModule& bleModule) : _bleModule(bleModule) {}
    void onConnect(BLEServer* pServer) {
        if (_bleModule.connectionCallback) {
            _bleModule.connectionCallback(pServer);
        }
    }
    void onDisconnect(BLEServer* pServer) {
        if (_bleModule.disconnectionCallback) {
            _bleModule.disconnectionCallback(pServer);
        }
    }
private:
    BLEModule& _bleModule;
};

/**
 * @class Callbacks
 * @brief A class to handle BLE characteristic read and write events.
 *
 * This class extends the BLECharacteristicCallbacks class and overrides its methods
 * to provide custom behavior for read and write operations on the BLE characteristics.
 */
class Callbacks : public BLECharacteristicCallbacks {
public:
    Callbacks(BLEModule& bleModule) : _bleModule(bleModule) {}
    void onWrite(BLECharacteristic* pCharacteristic) {
        if (_bleModule.writeCallback) {
            _bleModule.writeCallback(pCharacteristic);
        }
    }
    void onRead(BLECharacteristic* pCharacteristic) {
        if (_bleModule.readCallback) {
            _bleModule.readCallback(pCharacteristic);
        }
    }
private:
    BLEModule& _bleModule;
};

/**
 * @class DescriptorCallbacks
 * @brief A class to handle BLE descriptor read and write events.
 *
 * This class extends the BLEDescriptorCallbacks class and overrides its onWrite method
 * to provide custom behavior for enabling or disabling notifications on the BLE characteristics.
 *
 * @method onWrite
 * This method is called when a write request is received for the BLE2902 descriptor,
 * which is the standard descriptor for enabling or disabling notifications.
 * It handles the following cases:
 *   - When a value of 0x01 is written to the descriptor, it means the client has enabled notifications.
 *     The method will print "Notifications enabled" to the serial console.
 *   - When a value of 0x00 is written to the descriptor, it means the client has disabled notifications.
 *     The method will print "Notifications disabled" to the serial console.
 *
 * The method checks the written value to determine if notifications have been enabled or disabled.
 */
class DescriptorCallbacks : public BLEDescriptorCallbacks {
public:
    DescriptorCallbacks(BLEModule& bleModule) : _bleModule(bleModule) {}
    void onWrite(BLEDescriptor* pDescriptor) {
        if (_bleModule.descriptorWriteCallback) {
            _bleModule.descriptorWriteCallback(pDescriptor);
        }
    }
private:
    BLEModule& _bleModule;
};

/**
 * @brief Sets the value of a BLE characteristic to a specified string value.
 * 
 * @param pCharacteristic A pointer to the BLECharacteristic object to be updated.
 * @param value The string value to set for the characteristic.
 */
void BLEModule::setCharacteristicValue(BLECharacteristic* pCharacteristic, const std::string& value) {
    if (pCharacteristic != nullptr) { // Ensure the characteristic pointer is valid.
        pCharacteristic->setValue(value); // Set the value.
        pCharacteristic->notify(); // Notify connected clients about the change.
    }
}

/**
 * @brief Initializes the BLE module.
 *
 * This function initializes the BLE module, sets up the primary service and its
 * characteristic, and starts the BLE server. If the BLE module fails to start,
 * an error message is printed and the function returns false.
 *
 * @return True if the BLE module starts successfully, false otherwise.
 */
bool BLEModule::begin() {
    // Create the BLE Device
    BLEDevice::init(getDeviceName().c_str());

    // Configure BLE Security settings
    BLESecurity *pSecurity = new BLESecurity();
    pSecurity->setCapability(ESP_IO_CAP_NONE);
    pSecurity->setAuthenticationMode(ESP_LE_AUTH_REQ_SC_ONLY);

     // Create the BLE Server
    pServer = BLEDevice::createServer();
    pServer->setCallbacks(new ServerCallbacks(*this));

    // Create the BLE Service
    BLEService *pService = pServer->createService(PRIMARY_SERVICE_UUID);

    // Create the single BLE characteristic that will be used to communicate with the Brine module.
    BLECharacteristic *pOpenCharacteristic = pService->createCharacteristic(
        "abcd1234-1234-1234-1234-1234567890ab",
        BLECharacteristic::PROPERTY_READ |
        BLECharacteristic::PROPERTY_WRITE |
        BLECharacteristic::PROPERTY_NOTIFY
    );
    
    // Set callbacks on the open BLE characteristic
    pOpenCharacteristic->setCallbacks(new Callbacks(*this));
    BLEDescriptor* pOpenNotificationDescriptor = new BLE2902();
    pOpenNotificationDescriptor->setCallbacks(new DescriptorCallbacks(*this));
    pOpenCharacteristic->addDescriptor(pOpenNotificationDescriptor);

     // Set up security on the encrypted characteristic to utilize Just Works pairing
    pOpenCharacteristic->setAccessPermissions(ESP_GATT_PERM_READ_ENCRYPTED | ESP_GATT_PERM_WRITE_ENCRYPTED);

     // Start the service
    pService->start();

    debugService.debugPrintln("BLE module started");

    return true;
}

/**
 * @brief Sets the connection callback.
 */
void BLEModule::setConnectionCallback(BLEConnectionCallback callback) {
    connectionCallback = callback;
}

/**
 * @brief Sets the disconnection callback.
 */
void BLEModule::setDisconnectionCallback(BLEDisconnectionCallback callback) {
    disconnectionCallback = callback;
}

/**
 * @brief Sets the write callback.
 */
void BLEModule::setWriteCallback(BLEWriteCallback callback) {
    writeCallback = callback;
}

/**
 * @brief Sets the read callback.
 */
void BLEModule::setReadCallback(BLEReadCallback callback) {
    readCallback = callback;
}

/**
 * @brief Sets the descriptor write callback.
 */
void BLEModule::setDescriptorWriteCallback(BLEDescriptorWriteCallback callback) {
    descriptorWriteCallback = callback;
}

/**
 * @brief Ends the BLE module.
 *
 * This function calls the end() function of the BLE library to gracefully shut
 * down the BLE module. It should be called when you no longer need to use the
 * BLE module.
 */
void BLEModule::end() { 
    // Stop advertising
    pServer->getAdvertising()->stop();
}

/**
 * Starts advertising the BLE module.
 *
 * This function starts the advertisement process for the BLE module. It
 * configures the advertisement settings and starts advertising.
 *
 * @return True if the advertisement was started successfully, false otherwise.
 */
bool BLEModule::advertise() {
    // Start advertising
    pServer->getAdvertising()->start();

    return true;
}