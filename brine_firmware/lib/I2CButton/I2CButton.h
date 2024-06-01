#ifndef I2CBUTTON_H
#define I2CBUTTON_H

#include <SparkFun_Qwiic_Button.h>

#include "../../include/DebugService.h"

/**
 * @class I2CButton
 * @brief Represents a button that communicates over I2C.
 *
 * This singleton class provides functionality to interact with an I2C button.
 * It includes methods to initialize the button and to check its state.
 */
class I2CButton {
  public:
    /**
     * @brief Get the I2CButton instance.
     *
     * This method provides access to the singleton instance of the I2CButton
     * class.
     *
     * @return I2CButton& - The singleton instance of the I2CButton class.
     */
    static I2CButton &getInstance() {
        static I2CButton instance;
        return instance;
    }

    /**
     * @brief Initialize the I2CButton.
     *
     * This method initializes the I2CButton and sets the callback function to
     * be called when the button is pressed.
     *
     * @param callback - A pointer to the function to be called when the button
     * is pressed.
     * @return bool - Returns true if the initialization was successful, false
     * otherwise.
     */
    bool begin(void (*callback)());

    /**
     * @brief Clears the event bits, including the pressed and clicked bits.
     *
     * This method can be used to reset the button state.
     */
    void clearEventBits();

  private:
    /**
     * @brief Construct a new I2CButton object.
     *
     * This constructor is private because this class is a singleton.
     */
    I2CButton();

    /**
     * @brief The interrupt pin number.
     *
     * This is the pin number used for the interrupt signal from the button.
     */
    int interruptPin = 32;

    /**
     * @brief A reference to the DebugService singleton.
     *
     * This is used for debugging purposes.
     */
    DebugService &debugService = DebugService::getInstance();

    /**
     * @brief The QwiicButton object.
     *
     * This object represents the physical button.
     */
    QwiicButton button;

    /**
     * @brief Delete the copy constructor.
     *
     * This class cannot be copied because it is a singleton.
     */
    I2CButton(const I2CButton &) = delete;

    /**
     * @brief Delete the assignment operator.
     *
     * This class cannot be assigned because it is a singleton.
     */
    I2CButton &operator=(const I2CButton &) = delete;
};

#endif