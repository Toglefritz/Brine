#ifndef GPIOBUTTON_H
#define GPIOBUTTON_H

#include <Arduino.h>
#include "../../include/DebugService.h"

// Default pin for GPIO button - can be overridden with build flag
#ifndef GPIO_BUTTON_PIN
#define GPIO_BUTTON_PIN 8
#endif

/**
 * @class GPIOButton
 * @brief Represents a button connected directly to a GPIO pin.
 *
 * This singleton class provides functionality to interact with a GPIO button.
 * The button is expected to be wired between the specified GPIO pin and GND,
 * with an internal pull-up resistor enabled. It includes methods to initialize
 * the button, check its state, and attach interrupts for deep sleep wake-up.
 */
class GPIOButton {
public:
  /**
   * @brief Get the GPIOButton instance.
   *
   * This method provides access to the singleton instance of the GPIOButton class.
   *
   * @return GPIOButton& - The singleton instance of the GPIOButton class.
   */
  static GPIOButton &getInstance() {
    static GPIOButton instance;
    return instance;
  }

  /**
   * @brief Initialize the GPIO button.
   *
   * This method initializes the GPIO button by configuring the pin as input
   * with pull-up resistor and optionally attaching an interrupt handler.
   *
   * @param buttonHandler A function pointer to the button handler function (optional)
   * @return bool - Returns true if initialization was successful, false otherwise.
   */
  bool begin(void (*buttonHandler)() = nullptr);

  /**
   * @brief Checks if the button is currently pressed.
   *
   * @return true if the button is pressed (pin is LOW), false otherwise.
   */
  bool isPressed();

  /**
   * @brief Clears the event bits and resets button state.
   *
   * This method can be used to reset the button state and clear any pending events.
   */
  void clearEventBits();

  /**
   * @brief Attaches an interrupt to the button pin.
   *
   * @param buttonHandler Function pointer to the interrupt handler
   * @param mode Interrupt mode (FALLING, RISING, CHANGE, LOW, HIGH)
   * @return bool - Returns true if interrupt was attached successfully
   */
  bool attachInterrupt(void (*buttonHandler)(), int mode = FALLING);

  /**
   * @brief Detaches the interrupt from the button pin.
   */
  void detachInterrupt();

  /**
   * @brief Gets the GPIO pin number being used for the button.
   *
   * @return uint8_t - The GPIO pin number
   */
  uint8_t getPin() const { return buttonPin; }

  /**
   * @brief Configures the button pin for deep sleep wake-up.
   *
   * This method configures the button pin as an external wake-up source
   * for ESP32 deep sleep mode.
   *
   * @param wakeupLevel The logic level that will trigger wake-up (0 for LOW, 1 for HIGH)
   * @return bool - Returns true if wake-up source was configured successfully
   */
  bool enableDeepSleepWakeup(int wakeupLevel = 0);

private:
  /**
   * @brief Construct a new GPIOButton object.
   *
   * This constructor is private because this class is a singleton.
   */
  GPIOButton();

  /**
   * @brief The GPIO pin number for the button.
   */
  uint8_t buttonPin = GPIO_BUTTON_PIN;

  /**
   * @brief Flag indicating if the button has been initialized.
   */
  bool initialized = false;

  /**
   * @brief Flag indicating if an interrupt is currently attached.
   */
  bool interruptAttached = false;

  /**
   * @brief Reference to the DebugService singleton.
   */
  DebugService &debugService = DebugService::getInstance();

  /**
   * @brief Button state tracking for debouncing.
   */
  bool lastButtonState = HIGH;
  unsigned long lastDebounceTime = 0;
  static const unsigned long debounceDelay = 50; // 50ms debounce delay

  /**
   * @brief Delete the copy constructor.
   */
  GPIOButton(const GPIOButton &) = delete;

  /**
   * @brief Delete the assignment operator.
   */
  GPIOButton &operator=(const GPIOButton &) = delete;
};

#endif