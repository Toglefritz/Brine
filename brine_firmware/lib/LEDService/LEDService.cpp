#include "LEDService.h"

LEDService::LEDService() {}

/**
 * @brief Initializes the LED service with the appropriate hardware.
 *
 * Selects either the I2C LED or SK6812 LED based on compile-time configuration flags.
 */
#ifdef SK6812_LED
bool LEDService::begin(TwoWire &i2cBus, uint16_t numLeds) {
    debugService.debugPrintln("Initializing LEDService with SK6812 LED.");

    // Initialize SK6812 LED
    bool success = SK6812LED::getInstance().begin(numLeds);

    if (success) {
        // Set default color to blue with very low brightness
        SK6812LED::getInstance().setColor(0, 0, 128); // Dark blue (R=0, G=0, B=128)
        SK6812LED::getInstance().setBrightness(10); // Very low brightness (~4%)
        initialized = true;
        debugService.debugPrintln("SK6812 LED initialized successfully.");
    } else {
        debugService.debugPrintln("Failed to initialize SK6812 LED.");
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

#ifdef SK6812_LED
    currentState = true;
    return SK6812LED::getInstance().turnOn();
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

#ifdef SK6812_LED
    currentState = false;
    return SK6812LED::getInstance().turnOff();
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

#ifdef SK6812_LED
    bool result = SK6812LED::getInstance().blink(currentMillis, interval);
    // Update current state based on SK6812 state
    currentState = SK6812LED::getInstance().getState();
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
 * @brief Sets the LED color (SK6812 only).
 */
bool LEDService::setColor(uint8_t red, uint8_t green, uint8_t blue) {
    if (!initialized) {
        debugService.debugPrintln("LEDService not initialized.");
        return false;
    }

#ifdef SK6812_LED
    return SK6812LED::getInstance().setColor(red, green, blue);
#else
    // I2C LED doesn't support color changes, but return true for compatibility
    debugService.debugPrintln("Color setting not supported on I2C LED.");
    return true;
#endif
}

/**
 * @brief Sets the brightness level (SK6812 only).
 */
bool LEDService::setBrightness(uint8_t brightness) {
    if (!initialized) {
        debugService.debugPrintln("LEDService not initialized.");
        return false;
    }

#ifdef SK6812_LED
    return SK6812LED::getInstance().setBrightness(brightness);
#else
    // I2C LED doesn't support brightness control, but return true for compatibility
    debugService.debugPrintln("Brightness control not supported on I2C LED.");
    return true;
#endif
}

/**
 * @brief Returns the LED type being used.
 */
String LEDService::getLEDType() const {
#ifdef SK6812_LED
    return "SK6812";
#else
    return "I2C";
#endif
}

/**
 * @brief Returns the current LED state.
 */
bool LEDService::getState() const {
    if (!initialized) {
        return false;
    }

#ifdef SK6812_LED
    return SK6812LED::getInstance().getState();
#else
    return currentState;
#endif
}
