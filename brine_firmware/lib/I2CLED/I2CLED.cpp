#include "I2CLED.h"

I2CLED::I2CLED() {};

/**
 * @brief Initializes the I2CLED.
 *
 * This function initializes the I2CLED by joining the specified I2C bus and checking if
 * the LED acknowledges over I2C. If the LED does not acknowledge, the function freezes
 * the program.
 *
 * @param i2cBus A reference to the TwoWire instance representing the I2C bus to use.
 * @return true if initialization is successful, false otherwise.
 */
bool I2CLED::begin(TwoWire &i2cBus) {
  debugService.debugPrintln("Initializing I2CLED.");

  // Check if LED acknowledges over I2C
  if (led.begin((uint8_t)0x6F, i2cBus) == false) {
    debugService.debugPrintln("I2CLED failed to initialize. Freezing.");
    // TODO: Implement a better way to handle this error.
    while (1)
      ;
  }

  debugService.debugPrintln("I2CLED initialized.");

  // Turn the LED off initially
  led.LEDoff();

  return true;
}

/**
 * @brief Turns the LED on.
 *
 * This method turns the LED on at the current brightness level.
 */
bool I2CLED::turnOn() {
  isOn = true;
  lastChange = millis();

  return led.LEDon(brightness);
}

/**
 * @brief Turns the LED off.
 *
 * This method turns the LED off.
 */
bool I2CLED::turnOff() {
  isOn = false;
  lastChange = millis();

  return led.LEDoff();
}

/**
 * @brief Blinks the LED.
 */
bool I2CLED::blink(unsigned long currentMillis) {
  if (currentMillis - lastChange >= 500) {
    if (isOn) {
      return turnOff();
    } else {
      return turnOn();
    }
  }

  return true;
}