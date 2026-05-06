#ifndef SK6812LED_H
#define SK6812LED_H

#include <FastLED.h>
#include "../../include/DebugService.h"

// Default pin for SK6812 data line - can be overridden with build flag
// GPIO1 corresponds to D0/A0 pin on Seeed Studio XIAO ESP32-S3
#ifndef SK6812_DATA_PIN
#define SK6812_DATA_PIN 1
#endif

// Maximum number of LEDs supported
#ifndef SK6812_MAX_LEDS
#define SK6812_MAX_LEDS 64
#endif

/**
 * @class SK6812LED
 * @brief Controls an SK6812 RGB LED strip or individual LED.
 *
 * This singleton class provides color control, brightness adjustment, and visual
 * effects for SK6812 addressable LEDs. The SK6812 is driven via a single data pin
 * and is protocol-compatible with the WS2812B, using the same GRB color order.
 *
 * This implementation supports both single LEDs and multi-LED strips up to
 * SK6812_MAX_LEDS in length.
 */
class SK6812LED {
  public:
    /**
     * @brief Returns the singleton instance of SK6812LED.
     *
     * @return SK6812LED& The singleton instance.
     */
    static SK6812LED &getInstance() {
        static SK6812LED instance;
        return instance;
    }

    /**
     * @brief Initializes the SK6812 LED hardware.
     *
     * Configures FastLED for the SK6812 chipset using the compile-time defined
     * data pin (SK6812_DATA_PIN). All LEDs are turned off after initialization.
     *
     * @param numLeds The number of LEDs in the strip (default: 1).
     * @return true if initialization succeeded, false if numLeds exceeds SK6812_MAX_LEDS.
     */
    bool begin(uint16_t numLeds = 1);

    /**
     * @brief Turns the LED on with the current color and brightness.
     *
     * @return true if successful, false if the LED has not been initialized.
     */
    bool turnOn();

    /**
     * @brief Turns the LED off.
     *
     * @return true if successful, false if the LED has not been initialized.
     */
    bool turnOff();

    /**
     * @brief Sets the LED color using RGB values.
     *
     * @param red Red component (0-255).
     * @param green Green component (0-255).
     * @param blue Blue component (0-255).
     * @return true if successful, false if the LED has not been initialized.
     */
    bool setColor(uint8_t red, uint8_t green, uint8_t blue);

    /**
     * @brief Sets the LED color using a CRGB color object.
     *
     * @param color CRGB color to apply.
     * @return true if successful, false if the LED has not been initialized.
     */
    bool setColor(CRGB color);

    /**
     * @brief Sets the global brightness level.
     *
     * @param brightness Brightness level (0-255).
     * @return true if successful, false if the LED has not been initialized.
     */
    bool setBrightness(uint8_t brightness);

    /**
     * @brief Toggles the LED on and off at a specified interval.
     *
     * Call this repeatedly from the main loop. The LED state flips each time
     * the interval elapses.
     *
     * @param currentMillis The current time in milliseconds (from millis()).
     * @param interval The blink interval in milliseconds (default: 500ms).
     * @return true if successful, false if the LED has not been initialized.
     */
    bool blink(unsigned long currentMillis, unsigned long interval = 500);

    /**
     * @brief Cycles through hues to produce a rainbow effect.
     *
     * Call this repeatedly from the main loop. The hue advances each time
     * the speed interval elapses.
     *
     * @param currentMillis The current time in milliseconds (from millis()).
     * @param speed Delay between hue steps in milliseconds (lower = faster, default: 50).
     * @return true if successful, false if the LED has not been initialized.
     */
    bool rainbow(unsigned long currentMillis, unsigned long speed = 50);

    /**
     * @brief Produces a breathing (pulse) effect with the current color.
     *
     * Call this repeatedly from the main loop. Brightness ramps up and down
     * smoothly over time.
     *
     * @param currentMillis The current time in milliseconds (from millis()).
     * @param speed Delay between brightness steps in milliseconds (lower = faster, default: 20).
     * @return true if successful, false if the LED has not been initialized.
     */
    bool breathe(unsigned long currentMillis, unsigned long speed = 20);

    /**
     * @brief Returns whether the LED is currently on.
     *
     * @return true if the LED is on, false if off.
     */
    bool getState() const { return isOn; }

    /**
     * @brief Returns the current color setting.
     *
     * @return CRGB The current color.
     */
    CRGB getCurrentColor() const { return currentColor; }

  private:
    /**
     * @brief Private constructor for singleton pattern.
     */
    SK6812LED();

    /**
     * @brief Pushes the current LED buffer to the hardware.
     */
    void updateLED();

    /**
     * @brief Reference to the DebugService singleton.
     */
    DebugService &debugService = DebugService::getInstance();

    /**
     * @brief LED color buffer.
     */
    CRGB leds[SK6812_MAX_LEDS];

    /**
     * @brief Number of LEDs configured in the strip.
     */
    uint16_t numLeds = 1;

    /**
     * @brief Current brightness level (0-255).
     */
    uint8_t brightness = 128;

    /**
     * @brief Current color applied to the LEDs.
     */
    CRGB currentColor = CRGB::White;

    /**
     * @brief Whether the LED is currently displaying color.
     */
    bool isOn = false;

    /**
     * @brief Whether begin() has been called successfully.
     */
    bool initialized = false;

    /**
     * @brief Timestamp of the last state change, used by effects.
     */
    unsigned long lastChange = 0;

    /**
     * @brief Current hue position for the rainbow effect.
     */
    uint8_t rainbowHue = 0;

    /**
     * @brief Direction of brightness change for the breathe effect (1 = up, 0 = down).
     */
    uint8_t breatheDirection = 1;

    /**
     * @brief Current brightness level for the breathe effect.
     */
    uint8_t breatheBrightness = 0;

    SK6812LED(const SK6812LED &) = delete;
    SK6812LED &operator=(const SK6812LED &) = delete;
};

#endif
