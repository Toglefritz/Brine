#include "WS2812BLED.h"

WS2812BLED::WS2812BLED() {}

/**
 * @brief Initializes the WS2812B LED.
 *
 * This function initializes the WS2812B LED using the compile-time defined pin.
 * The pin is set via WS2812B_DATA_PIN macro (default: 2).
 *
 * @param numLeds The number of LEDs in the strip (default: 1)
 * @return true if initialization is successful, false otherwise.
 */
bool WS2812BLED::begin(uint16_t numLeds) {
    debugService.debugPrintln("Initializing WS2812B LED on pin " + String(WS2812B_DATA_PIN));
    
    if (numLeds > WS2812B_MAX_LEDS) {
        debugService.debugPrintln("Too many LEDs requested. Maximum: " + String(WS2812B_MAX_LEDS));
        return false;
    }
    
    this->numLeds = numLeds;
    
    // Initialize FastLED with compile-time pin specification
    FastLED.addLeds<WS2812B, WS2812B_DATA_PIN, GRB>(leds, numLeds).setCorrection(TypicalLEDStrip);
    FastLED.setBrightness(brightness);
    
    // Turn off all LEDs initially
    fill_solid(leds, numLeds, CRGB::Black);
    FastLED.show();
    
    initialized = true;
    debugService.debugPrintln("WS2812B LED initialized successfully.");
    
    return true;
}

/**
 * @brief Turns the LED on with the current color and brightness.
 */
bool WS2812BLED::turnOn() {
    if (!initialized) {
        debugService.debugPrintln("WS2812B LED not initialized.");
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
bool WS2812BLED::turnOff() {
    if (!initialized) {
        debugService.debugPrintln("WS2812B LED not initialized.");
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
bool WS2812BLED::setColor(uint8_t red, uint8_t green, uint8_t blue) {
    if (!initialized) {
        debugService.debugPrintln("WS2812B LED not initialized.");
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
bool WS2812BLED::setColor(CRGB color) {
    if (!initialized) {
        debugService.debugPrintln("WS2812B LED not initialized.");
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
 * @brief Sets the brightness level.
 */
bool WS2812BLED::setBrightness(uint8_t brightness) {
    if (!initialized) {
        debugService.debugPrintln("WS2812B LED not initialized.");
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
 * @brief Blinks the LED at a specified interval.
 */
bool WS2812BLED::blink(unsigned long currentMillis, unsigned long interval) {
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
 * @brief Creates a rainbow effect cycling through colors.
 */
bool WS2812BLED::rainbow(unsigned long currentMillis, unsigned long speed) {
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
 * @brief Creates a breathing effect with the current color.
 */
bool WS2812BLED::breathe(unsigned long currentMillis, unsigned long speed) {
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
 * @brief Updates the physical LED with current settings.
 */
void WS2812BLED::updateLED() {
    if (initialized) {
        FastLED.show();
    }
}