#ifndef ProvisioningManager_h
#define ProvisioningManager_h

class ProvisioningManager
{
public:
    /**
     * @brief Get the Instance object
     *
     * @return ProvisioningManager&
     */
    static ProvisioningManager &getInstance()
    {
        static ProvisioningManager instance;

        return instance;
    }

    /**
     * @brief Starts the provisioning process.
     *
     * This function is called when the button is pressed to initiate the provisioning process.
     * It wakes up the ESP32 from deep sleep and initializes the Bluetooth system.
     */
    void startProvisioning()
    {
        DebugService::getInstance().debugPrintln("Button pressed. Starting provisioning process.");

        // TODO(Toglefritz): Wake up the ESP32 from deep sleep.

        // Initialize the Bluetooth system.
        initializeBluetooth();
    }

    /**
     * Stops the provisioning process by ending the BLE module.
     */
    void stopProvisioning()
    {
        // End the BLE module
        BLEModule::getInstance().end();
    }

private:
    /**
     * @brief Private constructor to enforce singleton pattern.
     */
    ProvisioningManager() {};

    /**
     * @brief Initializes Bluetooth communication, which is used during the provisioning process.
     */
    void initializeBluetooth()
    {
        // Initialize the BLEModule
        bool bleBeginSuccess = BLEModule::getInstance().begin();

        if (!bleBeginSuccess)
        {
            DebugService::getInstance().debugPrintln("Failed to initialize BLE module.");
            return;
        }

        // Begin advertising over BLE
        bool bleAdvertiseSuccess = BLEModule::getInstance().advertise();

        if (!bleAdvertiseSuccess)
        {
            DebugService::getInstance().debugPrintln("Failed to start advertising.");
            return;
        }

        DebugService::getInstance().debugPrintln("Started advertising over BLE");
    }

    // Prevent copying and assignment
    ProvisioningManager(const ProvisioningManager &) = delete;
    ProvisioningManager &operator=(const ProvisioningManager &) = delete;
};

#endif // PROVISIONING_MANAGER_H