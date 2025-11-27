#ifndef DEEP_SLEEP_SERVICE_H
#define DEEP_SLEEP_SERVICE_H

#include <Arduino.h>
#include <esp_sleep.h>
#include "DebugService.h"

/**
 * @class DeepSleepService
 * @brief A singleton class that manages the deep sleep cycle of the ESP32 IoT device.
 *
 * The `DeepSleepService` class encapsulates the functionality required to handle the ESP32's
 * deep sleep capabilities. It allows the device to conserve power by entering a deep sleep state
 * and waking up periodically or when triggered by an external event, such as a button press.
 *
 * Features:
 * - **Timer Wake-Up**: Configures the ESP32 to wake up after a specified duration, enabling
 *   periodic tasks such as taking sensor readings and uploading data to a backend.
 * - **Button Wake-Up**: Configures a GPIO pin to wake the device when a button is pressed,
 *   allowing for manual wake-up and actions such as starting a provisioning process.
 * - **Wake-Up Cause Handling**: Determines the reason for the device waking up and triggers
 *   the corresponding actions, such as handling periodic tasks or responding to a button press.
 */
class DeepSleepService {
public:
  static DeepSleepService& getInstance() {
    static DeepSleepService instance;
    return instance;
  }

  /**
   * @brief Configures the deep sleep wake-up sources.
   *
   * Sets up the wake-up sources for deep sleep. This includes:
   * - Timer-based wake-up for periodic sensor readings.
   * - GPIO-based wake-up for button presses.
   *
   * @param sleepDurationMs Duration in milliseconds for the timer wake-up.
   * @param wakeUpPin GPIO pin connected to the button for wake-up.
   */
  void configureWakeUp(uint64_t sleepDurationMs, gpio_num_t wakeUpPin) {
    _sleepDurationMs = sleepDurationMs;
    _wakeUpPin = wakeUpPin;

    // Configure timer wake-up
    esp_sleep_enable_timer_wakeup(sleepDurationMs * 1000); // Convert to microseconds
    
    // Configure GPIO wake-up
    // Use ext1 for better compatibility across ESP32 variants
    // Button is active-low (pressed = LOW), so wake when ANY pin goes LOW
    uint64_t wakeupMask = 1ULL << wakeUpPin;
    esp_sleep_enable_ext1_wakeup(wakeupMask, ESP_EXT1_WAKEUP_ANY_LOW);
    
    DebugService::getInstance().debugPrint("DeepSleepService: Wake-up configured - Timer: ");
    DebugService::getInstance().debugPrint(String(sleepDurationMs));
    DebugService::getInstance().debugPrint("ms, GPIO: ");
    DebugService::getInstance().debugPrintln(String(wakeUpPin));
  }

  /**
   * @brief Configures button-only wake-up (no timer).
   *
   * Sets up only the GPIO wake-up source for deep sleep, without a timer.
   * This is useful when the device has no WiFi credentials and cannot perform
   * periodic sensor uploads.
   *
   * @param wakeUpPin GPIO pin connected to the button for wake-up.
   */
  void configureWakeUpButtonOnly(gpio_num_t wakeUpPin) {
    _wakeUpPin = wakeUpPin;
    _sleepDurationMs = 0; // No timer

    // Configure GPIO wake-up only
    // Button is active-low (pressed = LOW), so wake when ANY pin goes LOW
    uint64_t wakeupMask = 1ULL << wakeUpPin;
    esp_sleep_enable_ext1_wakeup(wakeupMask, ESP_EXT1_WAKEUP_ANY_LOW);
    
    DebugService::getInstance().debugPrint("DeepSleepService: Wake-up configured - Button only on GPIO: ");
    DebugService::getInstance().debugPrintln(String(wakeUpPin));
  }

  /**
   * @brief Puts the device into deep sleep.
   *
   * This method should be called after completing the sensor readings and uploading data
   * to the Firebase cloud. It ensures all necessary peripherals are disabled before sleeping.
   */
  void enterDeepSleep() {
    DebugService::getInstance().debugPrintln("DeepSleepService: Entering deep sleep...");
    // TODO Perform any cleanup operations if needed

    // Enter deep sleep
    esp_deep_sleep_start();
  }

private:
  uint64_t _sleepDurationMs;
  gpio_num_t _wakeUpPin;

  // Private constructor to enforce singleton pattern
  DeepSleepService() : _sleepDurationMs(0), _wakeUpPin(GPIO_NUM_MAX) {}
};

#endif // DEEP_SLEEP_SERVICE_H