#ifndef LEDSERVICE_H
#define LEDSERVICE_H

#include "../../include/DebugService.h"
#include <Wire.h>

// Conditional includes based on build configuration
#ifdef SK6812_LED
#include <SK6812LED.h>
#else
#include <I2CLED.h>
#endif

/**
 * @class LEDService
 * @brief A unified LED service that abstracts different LED hardware implementations.
 *
 * This singleton class provides a consistent interface for LED control regardless of
 * the underlying hardware (I2C LED or SK6812 RGB LED). The actual implementation
 * is selected at compile time based on build flags.
 *
 * Usage:
 * - For I2C LED: Default behavior, no special build flags needed
 * - For SK6812: Add -D SK6812_LED to build flags
 */
class LEDService {
  public:
    /**
     * @brief Returns the singleton instance of LEDService.
     *
     * @return LEDService& The singleton instance.
     */
    static LEDService &getInstance() {
        static LEDService instance;
        return instance;
    }

    /**
     * @brief Initializes the LED service with the appropriate hardware.
     *
     * Selects either the I2C LED or SK6812 LED based on compile-time configuration.
     *
     * @param i2cBus Reference to TwoWire I2C bus (only used for I2C LED).
     * @param numLeds Number of LEDs (only used for SK6812, default: 1).
     * @return true if initialization succeeded, false otherwise.
     */
#ifdef SK6812_LED
    bool begin(TwoWire &i2cBus = Wire, uint16_t numLeds = 1);
#else
    bool begin(TwoWire &i2cBus, uint16_t numLeds = 1);
#endif

    /**
     * @brief Turns the LED on.
     *
     * @return true if successful, false if the service has not been initialized.
     */
    bool turnOn();

    /**
     * @brief Turns the LED off.
     *
     * @return true if successful, false if the service has not been initialized.
     */
    bool turnOff();

    /**
     * @brief Blinks the LED at the specified interval.
     *
     * @param currentMillis The current time in milliseconds.
     * @param interval The blink interval in milliseconds (default: 500ms).
     * @return true if successful, false if the service has not been initialized.
     */
    bool blink(unsigned long currentMillis, unsigned long interval = 500);

    /**
     * @brief Sets the LED color (SK6812 only).
     *
     * For I2C LED, this method has no effect but returns true for compatibility.
     *
     * @param red Red component (0-255).
     * @param green Green component (0-255).
     * @param blue Blue component (0-255).
     * @return true if successful, false if the service has not been initialized.
     */
    bool setColor(uint8_t red, uint8_t green, uint8_t blue);

    /**
     * @brief Sets the brightness level (SK6812 only).
     *
     * For I2C LED, this method has no effect but returns true for compatibility.
     *
     * @param brightness Brightness level (0-255).
     * @return true if successful, false if the service has not been initialized.
     */
    bool setBrightness(uint8_t brightness);

    /**
     * @brief Returns the LED type being used.
     *
     * @return String "SK6812" or "I2C" depending on configuration.
     */
    String getLEDType() const;

    /**
     * @brief Returns the current LED state.
     *
     * @return true if LED is on, false if off.
     */
    bool getState() const;

  private:
    /**
     * @brief Private constructor for singleton pattern.
     */
    LEDService();

    /**
     * @brief Reference to the DebugService singleton.
     */
    DebugService &debugService = DebugService::getInstance();

    /**
     * @brief Whether the service has been initialized.
     */
    bool initialized = false;

    /**
     * @brief Current state of the LED (used for I2C LED tracking).
     */
    bool currentState = false;

    LEDService(const LEDService &) = delete;
    LEDService &operator=(const LEDService &) = delete;
};

#endif
