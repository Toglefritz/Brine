#include "I2CButton.h"

I2CButton::I2CButton(){};

/**
 * @brief Initializes the I2CButton.
 *
 * This function initializes the I2CButton by joining the I2C bus, configuring the interrupt pin,
 * and checking if the button acknowledges over I2C. If the button does not acknowledge, the
 * function freezes the program.
 *
 * @param buttonHandler A function pointer to the button handler function.
 */
bool I2CButton::begin(void (*buttonHandler)())
{
    debugService.debugPrintln("Initializing I2CButton.");

    pinMode(interruptPin, INPUT);
    attachInterrupt(digitalPinToInterrupt(interruptPin), buttonHandler, FALLING);

    // check if button will acknowledge over I2C
    if (button.begin() == false)
    {
        debugService.debugPrintln("I2CButton failed to initialize. Freezing.");
    
        return false;
    }
    debugService.debugPrintln("I2CButton initialized.");

    // Configure the interrupt pin to go low when we press the button.
    button.enablePressedInterrupt();

    // Configure the interrupt pin to go low when we click the button.
    button.enableClickedInterrupt();

    button.clearEventBits();

    return true;
}