#ifndef DEVICEMANAGER_H
#define DEVICEMANAGER_H

#include "../lib/I2CButton/I2CButton.h"

/**
 * @class DeviceManager
 * @brief This class serves as a centralized manager for all the devices used in the application.
 *
 * The DeviceManager class provides static methods to initialize and access these devices. This design choice has several advantages:
 * - Encapsulation: The details of device initialization and management are hidden from the rest of the application, making the code easier to understand and maintain.
 * - Single Responsibility Principle: The DeviceManager class has a single responsibility - to manage the devices. This makes the class easier to test and debug.
 * - Code Reusability: The same code can be reused across different parts of the application, reducing code duplication and making the codebase more maintainable.
 * - Ease of Modification: If a new device needs to be added or an existing one needs to be modified, only the DeviceManager class needs to be updated. This reduces the impact of changes and makes the codebase more robust.
 *
 * By not individually instantiating the devices in the main.cpp file, the code remains clean and focused on the application's main logic, while the details of device management are handled by the DeviceManager class. This separation of concerns leads to a more organized and maintainable codebase.
 */
class DeviceManager
{
public:
    /**
     * @brief Initializes the devices used in the application.
     *
     * This method initializes the devices used in the application, such as buttons, cryptographic modules, and
     * distance sensors. It should be called before using any device-related functionality.
     */
    static void initDevices(void (*buttonCallback)())
    {
        // Join I2C bus
        Wire.begin();

        // Initialize the I2CButton with the provided callback function
        button.getInstance().begin(buttonCallback);
    };

private:
    static I2CButton button;

    // Constructor made private to prevent instantiation
    DeviceManager();
};

#endif // DEVICEMANAGER_H