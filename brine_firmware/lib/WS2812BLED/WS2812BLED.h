#ifndef WS2812BLED_H
#define WS2812BLED_H

#include <FastLED.h>
#include "../../include/DebugService.h"

// Default pin for WS2812B data line - can be overridden with build flag
// GPIO1 corresponds to D0/A0 pin on Seeed Studio XIAO ESP32-S3
#ifndef WS2812B_DATA_PIN
#define WS2812B_DATA_PIN 1
#endif

// Maximum number of LEDs supported
#ifndef WS2812B_MAX_LEDS
#define WS2812B_MAX_LEDS 64
#endif

/**
 * @class WS2812BLED
 * @brief Represents a WS2812B RGB LED strip or individual LED.
 *
 * This singleton class provides functionality to interact with WS2812B RGB LEDs.
 * It includes methods to initialize the LED, control colors, brightness, and effects.
 * 
 * The WS2812B is controlled via a single data pin and can display millions of colors.
 * This implementation supports both single LEDs and LED strips.
 */
class WS2812BLED {
  public:
    /**
     * @brief Get the WS2812BLED instance.
     *
     * This method provides access to the singleton instance of the WS2812BLED class.
     *
     * @return WS2812BLED& - The singleton instance of the WS2812BLED class.
     */
    static WS2812BLED &getInstance() {
        static WS2812BLED instance;
        return instance;
    }

    /**
     * @brief Initialize the WS2812B LED.
     *
     * This method initializes the WS2812B LED using the compile-time defined pin.
     * The pin is set via WS2812B_DATA_PIN macro (default: 2).
     *
     * @param numLeds The number of LEDs in the strip (default: 1)
     * @return bool - Returns true if initialization was successful, false otherwise.
     */
    bool begin(uint16_t numLeds = 1);

    /**
     * @brief Turns the LED on with the current color and brightness.
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
     * @brief Sets the LED color using RGB values.
     *
     * @param red Red component (0-255)
     * @param green Green component (0-255)
     * @param blue Blue component (0-255)
     * @return bool - Returns true if successful, false otherwise.
     */
    bool setColor(uint8_t red, uint8_t green, uint8_t blue);

    /**
     * @brief Sets the LED color using a CRGB color object.
     *
     * @param color CRGB color object
     * @return bool - Returns true if successful, false otherwise.
     */
    bool setColor(CRGB color);

    /**
     * @brief Sets the brightness level.
     *
     * @param brightness Brightness level (0-255)
     * @return bool - Returns true if successful, false otherwise.
     */
    bool setBrightness(uint8_t brightness);

    /**
     * @brief Blinks the LED at a specified interval.
     *
     * @param currentMillis The current time in milliseconds
     * @param interval The blink interval in milliseconds (default: 500ms)
     * @return bool - Returns true if successful, false otherwise.
     */
    bool blink(unsigned long currentMillis, unsigned long interval = 500);

    /**
     * @brief Creates a rainbow effect cycling through colors.
     *
     * @param currentMillis The current time in milliseconds
     * @param speed Speed of the rainbow effect (lower = faster)
     * @return bool - Returns true if successful, false otherwise.
     */
    bool rainbow(unsigned long currentMillis, unsigned long speed = 50);

    /**
     * @brief Creates a breathing effect with the current color.
     *
     * @param currentMillis The current time in milliseconds
     * @param speed Speed of the breathing effect (lower = faster)
     * @return bool - Returns true if successful, false otherwise.
     */
    bool breathe(unsigned long currentMillis, unsigned long speed = 20);

    /**
     * @brief Gets the current LED state.
     *
     * @return bool - Returns true if LED is on, false if off.
     */
    bool getState() const { return isOn; }

    /**
     * @brief Gets the current color.
     *
     * @return CRGB - The current color.
     */
    CRGB getCurrentColor() const { return currentColor; }

  private:
    /**
     * @brief Construct a new WS2812BLED object.
     *
     * This constructor is private because this class is a singleton.
     */
    WS2812BLED();

    /**
     * @brief Updates the physical LED with current settings.
     */
    void updateLED();

    /**
     * @brief Reference to the DebugService singleton.
     */
    DebugService &debugService = DebugService::getInstance();

    /**
     * @brief Array of CRGB objects representing the LEDs.
     */
    CRGB leds[WS2812B_MAX_LEDS];

    /**
     * @brief Number of LEDs in the strip.
     */
    uint16_t numLeds = 1;

    /**
     * @brief Current brightness level (0-255).
     */
    uint8_t brightness = 32; // ~12.5% brightness

    /**
     * @brief Current color of the LED.
     */
    CRGB currentColor = CRGB::White;

    /**
     * @brief Flag indicating if the LED is currently on.
     */
    bool isOn = false;

    /**
     * @brief Flag indicating if the LED has been initialized.
     */
    bool initialized = false;

    /**
     * @brief Last time the LED state was changed (for effects).
     */
    unsigned long lastChange = 0;

    /**
     * @brief Effect state variables.
     */
    uint8_t rainbowHue = 0;
    uint8_t breatheDirection = 1;
    uint8_t breatheBrightness = 0;

    /**
     * @brief Delete the copy constructor.
     */
    WS2812BLED(const WS2812BLED &) = delete;

    /**
     * @brief Delete the assignment operator.
     */
    WS2812BLED &operator=(const WS2812BLED &) = delete;
};

#endif