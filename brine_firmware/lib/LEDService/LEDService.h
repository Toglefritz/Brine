#ifndef LEDSERVICE_H
#define LEDSERVICE_H

#include "../../include/DebugService.h"
#include <Wire.h>

// Conditional includes based on build configuration
#ifdef WS2812B_LED
#include <WS2812BLED.h>
#else
#include <I2CLED.h>
#endif

/**
 * @class LEDService
 * @brief A unified LED service that abstracts different LED hardware implementations.
 *
 * This singleton class provides a consistent interface for LED control regardless of
 * the underlying hardware (I2C LED or WS2812B RGB LED). The actual implementation
 * is selected at compile time based on build flags.
 *
 * Usage:
 * - For I2C LED: Default behavior, no special build flags needed
 * - For WS2812B: Add -D WS2812B_LED to build flags
 */
class LEDService {
  public:
    /**
     * @brief Get the LEDService instance.
     *
     * This method provides access to the singleton instance of the LEDService class.
     *
     * @return LEDService& - The singleton instance of the LEDService class.
     */
    static LEDService &getInstance() {
        static LEDService instance;
        return instance;
    }

    /**
     * @brief Initialize the LED service.
     *
     * This method initializes the appropriate LED hardware based on compile-time configuration.
     *
     * @param i2cBus Reference to TwoWire I2C bus (only used for I2C LED)
     * @param numLeds Number of LEDs (only used for WS2812B, default: 1)
     * @return bool - Returns true if initialization was successful, false otherwise.
     */
#ifdef WS2812B_LED
    bool begin(TwoWire &i2cBus = Wire, uint16_t numLeds = 1);
#else
    bool begin(TwoWire &i2cBus, uint16_t numLeds = 1);
#endif

    /**
     * @brief Turns the LED on.
     *
     * @return bool - Returns true if successful, false otherwise.
     */
    bool turnOn();

    /**
     * @brief Turns the LED off.
     *
     * @return bool - Returns true if successful, false otherwise.
     */
    bool turnOff();

    /**
     * @brief Blinks the LED at the specified interval.
     *
     * @param currentMillis The current time in milliseconds
     * @param interval The blink interval in milliseconds (default: 500ms)
     * @return bool - Returns true if successful, false otherwise.
     */
    bool blink(unsigned long currentMillis, unsigned long interval = 500);

    /**
     * @brief Sets the LED color (WS2812B only).
     *
     * For I2C LED, this method has no effect but returns true for compatibility.
     *
     * @param red Red component (0-255)
     * @param green Green component (0-255)
     * @param blue Blue component (0-255)
     * @return bool - Returns true if successful, false otherwise.
     */
    bool setColor(uint8_t red, uint8_t green, uint8_t blue);

    /**
     * @brief Sets the brightness level (WS2812B only).
     *
     * For I2C LED, this method has no effect but returns true for compatibility.
     *
     * @param brightness Brightness level (0-255)
     * @return bool - Returns true if successful, false otherwise.
     */
    bool setBrightness(uint8_t brightness);

    /**
     * @brief Gets the LED type being used.
     *
     * @return String - Returns "WS2812B" or "I2C" depending on configuration.
     */
    String getLEDType() const;

    /**
     * @brief Gets the current LED state.
     *
     * @return bool - Returns true if LED is on, false if off.
     */
    bool getState() const;

  private:
    /**
     * @brief Construct a new LEDService object.
     *
     * This constructor is private because this class is a singleton.
     */
    LEDService();

    /**
     * @brief Reference to the DebugService singleton.
     */
    DebugService &debugService = DebugService::getInstance();

    /**
     * @brief Flag indicating if the service has been initialized.
     */
    bool initialized = false;

    /**
     * @brief Current state of the LED (for I2C LED tracking).
     */
    bool currentState = false;

    /**
     * @brief Delete the copy constructor.
     */
    LEDService(const LEDService &) = delete;

    /**
     * @brief Delete the assignment operator.
     */
    LEDService &operator=(const LEDService &) = delete;
};

#endif