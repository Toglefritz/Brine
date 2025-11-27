#include "LEDService.h"

LEDService::LEDService() {}

/**
 * @brief Initializes the LED service with the appropriate hardware.
 *
 * This function initializes either the I2C LED or WS2812B LED based on
 * compile-time configuration flags.
 */
#ifdef WS2812B_LED
bool LEDService::begin(TwoWire &i2cBus, uint16_t numLeds) {
    debugService.debugPrintln("Initializing LEDService with WS2812B LED.");
    
    // Initialize WS2812B LED
    bool success = WS2812BLED::getInstance().begin(numLeds);
    
    if (success) {
        // Set default color to blue with very low brightness
        WS2812BLED::getInstance().setColor(0, 0, 128); // Dark blue (R=0, G=0, B=128)
        WS2812BLED::getInstance().setBrightness(10); // Very low brightness (~4%)
        initialized = true;
        debugService.debugPrintln("WS2812B LED initialized successfully.");
    } else {
        debugService.debugPrintln("Failed to initialize WS2812B LED.");
    }
    
    return success;
}
#else
bool LEDService::begin(TwoWire &i2cBus, uint16_t numLeds) {
    debugService.debugPrintln("Initializing LEDService with I2C LED.");
    
    // Initialize I2C LED (numLeds parameter is ignored for I2C LED)
    bool success = I2CLED::getInstance().begin(i2cBus);
    
    if (success) {
        initialized = true;
        debugService.debugPrintln("I2C LED initialized successfully.");
    } else {
        debugService.debugPrintln("Failed to initialize I2C LED.");
    }
    
    return success;
}
#endif

/**
 * @brief Turns the LED on.
 */
bool LEDService::turnOn() {
    if (!initialized) {
        debugService.debugPrintln("LEDService not initialized.");
        return false;
    }
    
#ifdef WS2812B_LED
    currentState = true;
    return WS2812BLED::getInstance().turnOn();
#else
    currentState = true;
    return I2CLED::getInstance().turnOn();
#endif
}

/**
 * @brief Turns the LED off.
 */
bool LEDService::turnOff() {
    if (!initialized) {
        debugService.debugPrintln("LEDService not initialized.");
        return false;
    }
    
#ifdef WS2812B_LED
    currentState = false;
    return WS2812BLED::getInstance().turnOff();
#else
    currentState = false;
    return I2CLED::getInstance().turnOff();
#endif
}

/**
 * @brief Blinks the LED at the specified interval.
 */
bool LEDService::blink(unsigned long currentMillis, unsigned long interval) {
    if (!initialized) {
        return false;
    }
    
#ifdef WS2812B_LED
    bool result = WS2812BLED::getInstance().blink(currentMillis, interval);
    // Update current state based on WS2812B state
    currentState = WS2812BLED::getInstance().getState();
    return result;
#else
    bool result = I2CLED::getInstance().blink(currentMillis);
    // For I2C LED, we need to track the state manually since blink() handles timing internally
    // The I2C LED blink method uses a fixed 500ms interval
    static unsigned long lastToggle = 0;
    if (currentMillis - lastToggle >= 500) {
        currentState = !currentState;
        lastToggle = currentMillis;
    }
    return result;
#endif
}

/**
 * @brief Sets the LED color (WS2812B only).
 */
bool LEDService::setColor(uint8_t red, uint8_t green, uint8_t blue) {
    if (!initialized) {
        debugService.debugPrintln("LEDService not initialized.");
        return false;
    }
    
#ifdef WS2812B_LED
    return WS2812BLED::getInstance().setColor(red, green, blue);
#else
    // I2C LED doesn't support color changes, but return true for compatibility
    debugService.debugPrintln("Color setting not supported on I2C LED.");
    return true;
#endif
}

/**
 * @brief Sets the brightness level (WS2812B only).
 */
bool LEDService::setBrightness(uint8_t brightness) {
    if (!initialized) {
        debugService.debugPrintln("LEDService not initialized.");
        return false;
    }
    
#ifdef WS2812B_LED
    return WS2812BLED::getInstance().setBrightness(brightness);
#else
    // I2C LED doesn't support brightness control, but return true for compatibility
    debugService.debugPrintln("Brightness control not supported on I2C LED.");
    return true;
#endif
}

/**
 * @brief Gets the LED type being used.
 */
String LEDService::getLEDType() const {
#ifdef WS2812B_LED
    return "WS2812B";
#else
    return "I2C";
#endif
}

/**
 * @brief Gets the current LED state.
 */
bool LEDService::getState() const {
    if (!initialized) {
        return false;
    }
    
#ifdef WS2812B_LED
    return WS2812BLED::getInstance().getState();
#else
    return currentState;
#endif
}