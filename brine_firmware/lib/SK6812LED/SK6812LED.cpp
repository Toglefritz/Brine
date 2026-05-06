#include "SK6812LED.h"

SK6812LED::SK6812LED() {}

/**
 * @brief Initializes the SK6812 LED hardware.
 *
 * Configures FastLED for the SK6812 chipset on the compile-time defined data pin.
 * Returns false without initializing if the requested LED count exceeds the
 * compile-time maximum (SK6812_MAX_LEDS).
 *
 * @param numLeds The number of LEDs in the strip (default: 1).
 * @return true if initialization succeeded.
 */
bool SK6812LED::begin(uint16_t numLeds) {
    debugService.debugPrintln("Initializing SK6812 LED on pin " + String(SK6812_DATA_PIN));

    if (numLeds > SK6812_MAX_LEDS) {
        debugService.debugPrintln("Too many LEDs requested. Maximum: " + String(SK6812_MAX_LEDS));
        return false;
    }

    this->numLeds = numLeds;

    // SK6812 uses GRB color order, same as WS2812B
    FastLED.addLeds<SK6812, SK6812_DATA_PIN, GRB>(leds, numLeds);
    FastLED.setBrightness(brightness);

    // Turn off all LEDs initially
    fill_solid(leds, numLeds, CRGB::Black);
    FastLED.show();

    initialized = true;
    debugService.debugPrintln("SK6812 LED initialized successfully.");

    return true;
}

/**
 * @brief Turns the LED on with the current color and brightness.
 */
bool SK6812LED::turnOn() {
    if (!initialized) {
        debugService.debugPrintln("SK6812 LED not initialized.");
        return false;
    }

    isOn = true;
    lastChange = millis();

    fill_solid(leds, numLeds, currentColor);
    updateLED();

    return true;
}

/**
 * @brief Turns the LED off.
 */
bool SK6812LED::turnOff() {
    if (!initialized) {
        debugService.debugPrintln("SK6812 LED not initialized.");
        return false;
    }

    isOn = false;
    lastChange = millis();

    fill_solid(leds, numLeds, CRGB::Black);
    updateLED();

    return true;
}

/**
 * @brief Sets the LED color using RGB values.
 */
bool SK6812LED::setColor(uint8_t red, uint8_t green, uint8_t blue) {
    if (!initialized) {
        debugService.debugPrintln("SK6812 LED not initialized.");
        return false;
    }

    currentColor = CRGB(red, green, blue);

    if (isOn) {
        fill_solid(leds, numLeds, currentColor);
        updateLED();
    }

    return true;
}

/**
 * @brief Sets the LED color using a CRGB color object.
 */
bool SK6812LED::setColor(CRGB color) {
    if (!initialized) {
        debugService.debugPrintln("SK6812 LED not initialized.");
        return false;
    }

    currentColor = color;

    if (isOn) {
        fill_solid(leds, numLeds, currentColor);
        updateLED();
    }

    return true;
}

/**
 * @brief Sets the global brightness level.
 */
bool SK6812LED::setBrightness(uint8_t brightness) {
    if (!initialized) {
        debugService.debugPrintln("SK6812 LED not initialized.");
        return false;
    }

    this->brightness = brightness;
    FastLED.setBrightness(brightness);

    if (isOn) {
        updateLED();
    }

    return true;
}

/**
 * @brief Toggles the LED on and off at a specified interval.
 */
bool SK6812LED::blink(unsigned long currentMillis, unsigned long interval) {
    if (!initialized) {
        return false;
    }

    if (currentMillis - lastChange >= interval) {
        if (isOn) {
            return turnOff();
        } else {
            return turnOn();
        }
    }

    return true;
}

/**
 * @brief Cycles through hues to produce a rainbow effect.
 */
bool SK6812LED::rainbow(unsigned long currentMillis, unsigned long speed) {
    if (!initialized) {
        return false;
    }

    if (currentMillis - lastChange >= speed) {
        lastChange = currentMillis;

        for (uint16_t i = 0; i < numLeds; i++) {
            leds[i] = CHSV(rainbowHue + (i * 255 / numLeds), 255, brightness);
        }

        rainbowHue++;
        updateLED();
        isOn = true;
    }

    return true;
}

/**
 * @brief Produces a breathing (pulse) effect with the current color.
 */
bool SK6812LED::breathe(unsigned long currentMillis, unsigned long speed) {
    if (!initialized) {
        return false;
    }

    if (currentMillis - lastChange >= speed) {
        lastChange = currentMillis;

        if (breatheDirection == 1) {
            breatheBrightness += 2;
            if (breatheBrightness >= brightness) {
                breatheBrightness = brightness;
                breatheDirection = 0;
            }
        } else {
            breatheBrightness -= 2;
            if (breatheBrightness <= 5) {
                breatheBrightness = 5;
                breatheDirection = 1;
            }
        }

        CRGB dimmedColor = currentColor;
        dimmedColor.nscale8(breatheBrightness);

        fill_solid(leds, numLeds, dimmedColor);
        FastLED.setBrightness(255); // Use full brightness, color is already dimmed
        FastLED.show();
        FastLED.setBrightness(brightness); // Restore original brightness

        isOn = true;
    }

    return true;
}

/**
 * @brief Pushes the current LED buffer to the hardware.
 */
void SK6812LED::updateLED() {
    if (initialized) {
        FastLED.show();
    }
}
