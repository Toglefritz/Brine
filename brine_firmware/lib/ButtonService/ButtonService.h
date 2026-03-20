#ifndef BUTTONSERVICE_H
#define BUTTONSERVICE_H

#include "../../include/DebugService.h"

// Conditional includes based on build configuration
#ifdef GPIO_BUTTON
#include <GPIOButton.h>
#else
#include <I2CButton.h>
#include <Wire.h>
#endif

/**
 * @class ButtonService
 * @brief A unified button service that abstracts different button hardware implementations.
 *
 * This singleton class provides a consistent interface for button control regardless of
 * the underlying hardware (I2C button or GPIO button). The actual implementation
 * is selected at compile time based on build flags.
 *
 * Usage:
 * - For I2C Button: Default behavior, no special build flags needed
 * - For GPIO Button: Add -D GPIO_BUTTON to build flags
 */
class ButtonService {
  public:
    /**
     * @brief Get the ButtonService instance.
     *
     * This method provides access to the singleton instance of the ButtonService class.
     *
     * @return ButtonService& - The singleton instance of the ButtonService class.
     */
    static ButtonService &getInstance() {
        static ButtonService instance;
        return instance;
    }

    /**
     * @brief Initialize the button service.
     *
     * This method initializes the appropriate button hardware based on compile-time configuration.
     *
     * @param i2cBus Reference to TwoWire I2C bus (only used for I2C button)
     * @param buttonHandler Function pointer to interrupt handler
     * @return bool - Returns true if initialization was successful, false otherwise.
     */
#ifdef GPIO_BUTTON
    bool begin(TwoWire &i2cBus, void (*buttonHandler)());
    bool begin(void (*buttonHandler)());
#else
    bool begin(TwoWire &i2cBus, void (*buttonHandler)());
#endif

    /**
     * @brief Checks if the button is currently pressed.
     *
     * @return bool - Returns true if button is pressed, false otherwise.
     */
    bool isPressed();

    /**
     * @brief Clears the event bits and resets button state.
     */
    void clearEventBits();

    /**
     * @brief Gets the button type being used.
     *
     * @return String - Returns "GPIO" or "I2C" depending on configuration.
     */
    String getButtonType() const;

    /**
     * @brief Enables deep sleep wake-up (GPIO button only).
     *
     * For I2C button, this method has no effect but returns true for compatibility.
     *
     * @param wakeupLevel The logic level that triggers wake-up (0=LOW, 1=HIGH)
     * @return bool - Returns true if successful, false otherwise.
     */
    bool enableDeepSleepWakeup(int wakeupLevel = 0);

    /**
     * @brief Gets the button pin number (GPIO button only).
     *
     * For I2C button, returns 0.
     *
     * @return uint8_t - The GPIO pin number or 0 for I2C button.
     */
    uint8_t getPin() const;

  private:
    /**
     * @brief Construct a new ButtonService object.
     *
     * This constructor is private because this class is a singleton.
     */
    ButtonService();

    /**
     * @brief Reference to the DebugService singleton.
     */
    DebugService &debugService = DebugService::getInstance();

    /**
     * @brief Flag indicating if the service has been initialized.
     */
    bool initialized = false;

    /**
     * @brief Delete the copy constructor.
     */
    ButtonService(const ButtonService &) = delete;

    /**
     * @brief Delete the assignment operator.
     */
    ButtonService &operator=(const ButtonService &) = delete;
};

#endif