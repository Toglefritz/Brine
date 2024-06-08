#ifndef ProvisioningManager_h
#define ProvisioningManager_h

class ProvisioningManager {
  public:
    /**
     * @brief Get the Instance object
     *
     * @return ProvisioningManager&
     */
    static ProvisioningManager &getInstance() {
        static ProvisioningManager instance;

        return instance;
    }

    /**
     * @brief Starts the provisioning process.
     *
     * This function is called when the button is pressed to initiate the provisioning process. It wakes up the ESP32 
     * from deep sleep and initializes the Bluetooth system.
     */
    void startProvisioning() {
        DebugService::getInstance().debugPrintln(
            "Button pressed. Starting provisioning process.");

        // TODO(Toglefritz): Wake up the ESP32 from deep sleep.

        // Initialize the Bluetooth system.
        initializeBluetooth();
    }

    /**
     * Stops the provisioning process by ending the BLE module.
     */
    void stopProvisioning() {
        // End the BLE module
        bleModule.end();
    }

    /**
     * @brief Sets the callback function for handling BLE connection events.
     *
     * @param callback The callback function to be set.
     */
    void setExternalConnectionCallback(BLEConnectionCallback callback) {
        externalConnectionCallback = callback;
    }

    /**
     * @brief Sets the callback function for handling BLE disconnection events.
     *
     * @param callback The callback function to be set.
     */
    void setExternalDisconnectionCallback(BLEDisconnectionCallback callback) {
        externalDisconnectionCallback = callback;
    }

    /**
     * @brief Sets the callback function for handling BLE write events.
     *
     * @param callback The callback function to be set.
     */
    void setExternalWriteCallback(BLEWriteCallback callback) {
        externalWriteCallback = callback;
    }

    /**
     * @brief Sets the callback function for handling BLE read events.
     *
     * @param callback The callback function to be set.
     */
    void setExternalReadCallback(BLEReadCallback callback) {
        externalReadCallback = callback;
    }

    /**
     * @brief Sets the callback function for handling BLE descriptor write
     * events.
     *
     * @param callback The callback function to be set.
     */
    void
    setExternalDescriptorWriteCallback(BLEDescriptorWriteCallback callback) {
        externalDescriptorWriteCallback = callback;
    }

  private:
    // Instance of BLEModule
    BLEModule bleModule;

    /**
     * @brief External callback for handling BLE connection events.
     */
    BLEConnectionCallback externalConnectionCallback;

    /**
     * @brief External callback for handling BLE disconnection events.
     */
    BLEDisconnectionCallback externalDisconnectionCallback;

    /**
     * @brief External callback for handling BLE characteristic write events.
     */
    BLEWriteCallback externalWriteCallback;

    /**
     * @brief External callback for handling BLE characteristic read events.
     */
    BLEReadCallback externalReadCallback;

    /**
     * @brief External callback for handling BLE descriptor write events.
     */
    BLEDescriptorWriteCallback externalDescriptorWriteCallback;

    /**
     * @brief Private constructor to enforce singleton pattern.
     */
    ProvisioningManager() {
        // Register BLE callbacks
        bleModule.setConnectionCallback([this](BLEServer *pServer) {
            DebugService::getInstance().debugPrintln("Device connected");
            if (externalConnectionCallback)
                externalConnectionCallback(pServer);
        });

        bleModule.setDisconnectionCallback([this](BLEServer *pServer) {
            DebugService::getInstance().debugPrintln("Device disconnected");
            if (externalDisconnectionCallback)
                externalDisconnectionCallback(pServer);
        });

        bleModule.setWriteCallback([this](BLECharacteristic *pCharacteristic) {
            std::string value = pCharacteristic->getValue();
            DebugService::getInstance().debugPrintln(
                "Characteristic written: " + String(value.c_str()));
            if (externalWriteCallback)
                externalWriteCallback(pCharacteristic);
        });

        bleModule.setReadCallback([this](BLECharacteristic *pCharacteristic) {
            DebugService::getInstance().debugPrintln("Characteristic read");
            if (externalReadCallback)
                externalReadCallback(pCharacteristic);
        });

        bleModule.setDescriptorWriteCallback(
            [this](BLEDescriptor *pDescriptor) {
                uint8_t *data = pDescriptor->getValue();
                if (data[0] == 0x01) {
                    DebugService::getInstance().debugPrintln(
                        "Notifications enabled");
                } else if (data[0] == 0x00) {
                    DebugService::getInstance().debugPrintln(
                        "Notifications disabled");
                }
                if (externalDescriptorWriteCallback)
                    externalDescriptorWriteCallback(pDescriptor);
            });
    }

    /**
     * @brief Initializes Bluetooth communication, which is used during the provisioning process.
     */
    void initializeBluetooth() {
        // Initialize the BLEModule
        bool bleBeginSuccess = bleModule.begin();

        if (!bleBeginSuccess) {
            DebugService::getInstance().debugPrintln(
                "Failed to initialize BLE module.");
            return;
        }

        // Begin advertising over BLE
        bool bleAdvertiseSuccess = bleModule.advertise();

        if (!bleAdvertiseSuccess) {
            DebugService::getInstance().debugPrintln(
                "Failed to start advertising.");
            return;
        }

        DebugService::getInstance().debugPrintln(
            "Started advertising over BLE");
    }

    // Prevent copying and assignment
    ProvisioningManager(const ProvisioningManager &) = delete;
    ProvisioningManager &operator=(const ProvisioningManager &) = delete;
};

#endif // PROVISIONING_MANAGER_H