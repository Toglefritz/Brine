#ifndef I2CLED_H
#define I2CLED_H

#include <SparkFun_Qwiic_Button.h>

#include "../../include/DebugService.h"

/**
 * @class I2CLED
 * @brief Represents an LED that communicates over I2C.
 *
 * This singleton class provides functionality to interact with an I2C LED.
 * It includes methods to initialize the LED and turn it on or off.
 *
 * The LED is part of the Qwiic Button, which is a tactile button with an integrated LED. However, this class, and
 * the I2CButton class, treat the LED as a separate entity for ease of use and the ability to integrate different
 * hardware in the future.
 */
class I2CLED
{
public:
    /**
     * @brief Get the I2CLED instance.
     *
     * This method provides access to the singleton instance of the I2CLED class.
     *
     * @return I2CLED& - The singleton instance of the I2CLED class.
     */
    static I2CLED &getInstance()
    {
        static I2CLED instance;

        return instance;
    }

    /**
     * @brief Initialize the I2CLED.
     *
     * This method initializes the I2CLED.
     *
     * @return bool - Returns true if the initialization was successful, false otherwise.
     */
    bool begin();

    /**
     * @brief Turns the LED on.
     *
     * This method turns the LED on at the current brightness level.
     */
    void turnOn();

    /**
     * @brief Turns the LED off.
     *
     * This method turns the LED off.
     */
    void turnOff();

private:
    /**
     * @brief Construct a new I2CLED object.
     *
     * This constructor is private because this class is a singleton.
     */
    I2CLED();

    /**
     * @brief The brightness level of the LED.
     *
     * This is a value between 0 (off) and 255 (full brightness).
     */
    int brightness = 128 /* 50% brightness */;

    /**
     * @brief A reference to the DebugService singleton.
     *
     * This is used for debugging purposes.
     */
    DebugService &debugService = DebugService::getInstance();

    /**
     * @brief The QwiicButton object representing the physical LED inside the tactile button.
     *
     * This object represents the physical LED connected via I2C.
     */
    QwiicButton led;

    /**
     * @brief Delete the copy constructor.
     *
     * This class cannot be copied because it is a singleton.
     */
    I2CLED(const I2CLED &) = delete;

    /**
     * @brief Delete the assignment operator.
     *
     * This class cannot be assigned because it is a singleton.
     */
    I2CLED &operator=(const I2CLED &) = delete;
};

#endif