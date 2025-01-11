#include "I2CButton.h"

I2CButton::I2CButton() {};

/**
 * @brief Initializes the I2CButton.
 *
 * This function initializes the I2CButton by joining the I2C bus, configuring
 * the interrupt pin, and checking if the button acknowledges over I2C. If the
 * button does not acknowledge, the function freezes the program.
 *
 * @param buttonHandler A function pointer to the button handler function.
 */
bool I2CButton::begin(TwoWire &i2cBus, void (*buttonHandler)()) {
  debugService.debugPrintln("Initializing I2CButton.");

  pinMode(interruptPin, INPUT);
  attachInterrupt(digitalPinToInterrupt(interruptPin), buttonHandler, FALLING);

  // Check if button will acknowledge over I2C.
  if (button.begin((uint8_t)0x6F, i2cBus) == false) {
    debugService.debugPrintln("I2CButton failed to initialize. Device did not acknowledge.");

    return false;
  }

  debugService.debugPrintln("I2CButton initialized.");

  // Configure the interrupt pin to go low when the button is clicked.
  button.enableClickedInterrupt();

  button.enablePressedInterrupt();

  button.clearEventBits();

  return true;
}

/**
 * @brief Checks if the button is currently pressed.
 *
 * @return true if the button is pressed, false otherwise.
 */
bool I2CButton::isPressed() {
  return button.isPressed();
}

/**
 * @brief Clears the event bits, including the pressed and clicked bits.
 *
 * This method can be used to reset the button state.
 */
void I2CButton::clearEventBits() { button.clearEventBits(); }