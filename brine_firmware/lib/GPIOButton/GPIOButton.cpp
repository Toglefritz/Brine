#include "GPIOButton.h"
#include <esp_sleep.h>

GPIOButton::GPIOButton() {}

/**
 * @brief Initializes the GPIO button.
 *
 * This function configures the specified GPIO pin as an input with internal
 * pull-up resistor enabled. The button is expected to be wired between the
 * GPIO pin and GND. Optionally attaches an interrupt handler.
 *
 * @param buttonHandler Optional function pointer to interrupt handler
 * @return true if initialization is successful, false otherwise.
 */
bool GPIOButton::begin(void (*buttonHandler)()) {
    debugService.debugPrintln("Initializing GPIO Button on pin " + String(buttonPin));
    
    // Configure the pin as input with pull-up resistor
    pinMode(buttonPin, INPUT_PULLUP);
    
    // Initialize button state
    lastReading = digitalRead(buttonPin);
    lastButtonState = lastReading;
    lastDebounceTime = millis();
    
    // Attach interrupt if handler is provided
    if (buttonHandler != nullptr) {
        if (!attachInterrupt(buttonHandler, FALLING)) {
            debugService.debugPrintln("Failed to attach interrupt to GPIO button.");
            return false;
        }
    }
    
    initialized = true;
    debugService.debugPrintln("GPIO Button initialized successfully on pin " + String(buttonPin));
    
    return true;
}

/**
 * @brief Checks if the button is currently pressed.
 *
 * This method reads the GPIO pin state and applies debouncing logic.
 * The button is considered pressed when the pin reads LOW (connected to GND).
 *
 * @return true if button is pressed (debounced), false otherwise.
 */
bool GPIOButton::isPressed() {
    if (!initialized) {
        return false;
    }
    
    bool currentReading = digitalRead(buttonPin);
    unsigned long currentTime = millis();
    
    // If the reading has changed, reset the debounce timer
    if (currentReading != lastReading) {
        lastDebounceTime = currentTime;
        lastReading = currentReading;
    }
    
    // If enough time has passed since the last change, update the stable button state
    if ((currentTime - lastDebounceTime) > debounceDelay) {
        lastButtonState = currentReading;
    }
    
    // Button is pressed when pin is LOW (connected to GND)
    return (lastButtonState == LOW);
}

/**
 * @brief Clears the event bits and resets button state.
 *
 * This method resets the button state tracking variables.
 */
void GPIOButton::clearEventBits() {
    if (!initialized) {
        return;
    }
    
    lastReading = digitalRead(buttonPin);
    lastButtonState = lastReading;
    lastDebounceTime = millis();
    
    debugService.debugPrintln("GPIO Button event bits cleared.");
}

/**
 * @brief Attaches an interrupt to the button pin.
 *
 * @param buttonHandler Function pointer to the interrupt handler
 * @param mode Interrupt mode (FALLING, RISING, CHANGE, LOW, HIGH)
 * @return true if interrupt was attached successfully, false otherwise.
 */
bool GPIOButton::attachInterrupt(void (*buttonHandler)(), int mode) {
    if (!initialized) {
        debugService.debugPrintln("GPIO Button not initialized. Cannot attach interrupt.");
        return false;
    }
    
    if (interruptAttached) {
        debugService.debugPrintln("Interrupt already attached to GPIO button. Detaching first.");
        detachInterrupt();
    }
    
    // Attach the interrupt
    ::attachInterrupt(digitalPinToInterrupt(buttonPin), buttonHandler, mode);
    interruptAttached = true;
    
    debugService.debugPrintln("Interrupt attached to GPIO button pin " + String(buttonPin));
    return true;
}

/**
 * @brief Detaches the interrupt from the button pin.
 */
void GPIOButton::detachInterrupt() {
    if (!initialized || !interruptAttached) {
        return;
    }
    
    ::detachInterrupt(digitalPinToInterrupt(buttonPin));
    interruptAttached = false;
    
    debugService.debugPrintln("Interrupt detached from GPIO button pin " + String(buttonPin));
}

/**
 * @brief Configures the button pin for deep sleep wake-up.
 *
 * This method configures the button pin as an external wake-up source
 * for ESP32 deep sleep mode. On the ESP32-C3, uses the deep sleep GPIO
 * wakeup API. On other variants, uses ext1 wake-up through RTC GPIO.
 *
 * @param wakeupLevel The logic level that will trigger wake-up (0 for LOW, 1 for HIGH)
 * @return true if wake-up source was configured successfully, false otherwise.
 */
bool GPIOButton::enableDeepSleepWakeup(int wakeupLevel) {
    if (!initialized) {
        debugService.debugPrintln("GPIO Button not initialized. Cannot enable deep sleep wake-up.");
        return false;
    }
    
    uint64_t buttonMask = 1ULL << buttonPin;
    esp_err_t result;

#if defined(CONFIG_IDF_TARGET_ESP32C3)
    // The ESP32-C3 uses the deep sleep GPIO wakeup API rather than EXT1.
    if (wakeupLevel == 0) {
        result = esp_deep_sleep_enable_gpio_wakeup(buttonMask, ESP_GPIO_WAKEUP_GPIO_LOW);
    } else {
        result = esp_deep_sleep_enable_gpio_wakeup(buttonMask, ESP_GPIO_WAKEUP_GPIO_HIGH);
    }
#else
    if (wakeupLevel == 0) {
        result = esp_sleep_enable_ext1_wakeup(buttonMask, ESP_EXT1_WAKEUP_ANY_LOW);
    } else {
        result = esp_sleep_enable_ext1_wakeup(buttonMask, ESP_EXT1_WAKEUP_ANY_HIGH);
    }
#endif
    
    if (result == ESP_OK) {
        debugService.debugPrintln("Deep sleep wake-up enabled on GPIO button pin " + String(buttonPin) + 
                                 " with level " + String(wakeupLevel));
        return true;
    } else {
        debugService.debugPrintln("Failed to enable deep sleep wake-up on GPIO button. Error: " + String(result));
        return false;
    }
}