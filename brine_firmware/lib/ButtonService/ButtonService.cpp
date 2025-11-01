#include "ButtonService.h"

ButtonService::ButtonService() {}

#ifdef GPIO_BUTTON
/**
 * @brief Initializes the button service with GPIO button (I2C bus parameter ignored).
 */
bool ButtonService::begin(TwoWire &i2cBus, void (*buttonHandler)()) {
    debugService.debugPrintln("Initializing ButtonService with GPIO Button.");
    
    bool success = GPIOButton::getInstance().begin(buttonHandler);
    
    if (success) {
        initialized = true;
        debugService.debugPrintln("GPIO Button initialized successfully on pin " + String(GPIOButton::getInstance().getPin()));
    } else {
        debugService.debugPrintln("Failed to initialize GPIO Button.");
    }
    
    return success;
}

/**
 * @brief Initializes the button service with GPIO button (simplified interface).
 */
bool ButtonService::begin(void (*buttonHandler)()) {
    debugService.debugPrintln("Initializing ButtonService with GPIO Button.");
    
    bool success = GPIOButton::getInstance().begin(buttonHandler);
    
    if (success) {
        initialized = true;
        debugService.debugPrintln("GPIO Button initialized successfully on pin " + String(GPIOButton::getInstance().getPin()));
    } else {
        debugService.debugPrintln("Failed to initialize GPIO Button.");
    }
    
    return success;
}
#else
/**
 * @brief Initializes the button service with I2C button.
 */
bool ButtonService::begin(TwoWire &i2cBus, void (*buttonHandler)()) {
    debugService.debugPrintln("Initializing ButtonService with I2C Button.");
    
    bool success = I2CButton::getInstance().begin(i2cBus, buttonHandler);
    
    if (success) {
        initialized = true;
        debugService.debugPrintln("I2C Button initialized successfully.");
    } else {
        debugService.debugPrintln("Failed to initialize I2C Button.");
    }
    
    return success;
}
#endif

/**
 * @brief Checks if the button is currently pressed.
 */
bool ButtonService::isPressed() {
    if (!initialized) {
        return false;
    }
    
#ifdef GPIO_BUTTON
    return GPIOButton::getInstance().isPressed();
#else
    return I2CButton::getInstance().isPressed();
#endif
}

/**
 * @brief Clears the event bits and resets button state.
 */
void ButtonService::clearEventBits() {
    if (!initialized) {
        return;
    }
    
#ifdef GPIO_BUTTON
    GPIOButton::getInstance().clearEventBits();
#else
    I2CButton::getInstance().clearEventBits();
#endif
}

/**
 * @brief Gets the button type being used.
 */
String ButtonService::getButtonType() const {
#ifdef GPIO_BUTTON
    return "GPIO";
#else
    return "I2C";
#endif
}

/**
 * @brief Enables deep sleep wake-up (GPIO button only).
 */
bool ButtonService::enableDeepSleepWakeup(int wakeupLevel) {
    if (!initialized) {
        debugService.debugPrintln("ButtonService not initialized.");
        return false;
    }
    
#ifdef GPIO_BUTTON
    return GPIOButton::getInstance().enableDeepSleepWakeup(wakeupLevel);
#else
    // I2C button doesn't support deep sleep wake-up directly, but return true for compatibility
    debugService.debugPrintln("Deep sleep wake-up not supported on I2C button.");
    return true;
#endif
}

/**
 * @brief Gets the button pin number (GPIO button only).
 */
uint8_t ButtonService::getPin() const {
    if (!initialized) {
        return 0;
    }
    
#ifdef GPIO_BUTTON
    return GPIOButton::getInstance().getPin();
#else
    // I2C button doesn't have a specific GPIO pin
    return 0;
#endif
}