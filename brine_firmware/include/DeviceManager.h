#pragma once
//#include "QwiicButton.h"
//#include "QwiicCrypto.h"
//#include "QwiicDistanceSensor.h"

/**
 * @class DeviceManager
 * @brief Manages the devices used in the application.
 *
 * The DeviceManager class provides static methods to initialize and access the devices used in the application.
 * It prevents instantiation by making the constructor private.
 */
class DeviceManager {
public:
    /**
     * @brief Initializes the devices used in the application.
     *
     * This method initializes the devices used in the application, such as buttons, cryptographic modules, and 
     * distance sensors. It should be called before using any device-related functionality.
     */
    static void initDevices();

    //static QwiicButton& getButtonInstance();
    //static QwiicCrypto& getCryptoInstance();
    //static QwiicDistanceSensor& getDistanceSensorInstance();
private:
    //static QwiicButton button;
    //static QwiicCrypto crypto;
    //static QwiicDistanceSensor distanceSensor;
    
    // Constructor made private to prevent instantiation
    DeviceManager();
};