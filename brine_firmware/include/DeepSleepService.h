#ifndef DEEP_SLEEP_SERVICE_H
#define DEEP_SLEEP_SERVICE_H

#include <Arduino.h>
#include <esp_sleep.h>
#include <driver/gpio.h>
#include "DebugService.h"

// The ESP32-C3 does not have RTC GPIO or EXT1 wakeup support. It uses the
// deep sleep GPIO wakeup API instead. Other ESP32 variants (original, S2, S3)
// use the RTC subsystem for GPIO wakeup during deep sleep.
#if !defined(CONFIG_IDF_TARGET_ESP32C3)
#include <driver/rtc_io.h>
#endif

/**
 * @class DeepSleepService
 * @brief Manages the deep sleep cycle for the ESP32.
 *
 * This singleton configures timer-based and GPIO-based wake-up sources, then
 * puts the device into deep sleep. The GPIO wake-up path allows the user to
 * wake the device by pressing a button, while the timer path enables periodic
 * sensor readings and data uploads.
 *
 * Platform differences between ESP32 variants are handled internally via
 * compile-time checks. On the ESP32-C3, GPIO wakeup uses
 * esp_deep_sleep_enable_gpio_wakeup(). On other variants, EXT1 wakeup with
 * RTC GPIO is used.
 */
class DeepSleepService {
public:
  static DeepSleepService& getInstance() {
    static DeepSleepService instance;
    return instance;
  }

  /**
   * @brief Configures both timer and GPIO wake-up sources for deep sleep.
   *
   * @param sleepDurationMs Duration in milliseconds for the timer wake-up.
   * @param wakeUpPin GPIO pin connected to the button for wake-up.
   */
  void configureWakeUp(uint64_t sleepDurationMs, gpio_num_t wakeUpPin) {
    _sleepDurationMs = sleepDurationMs;
    _wakeUpPin = wakeUpPin;

    // Configure timer wake-up (microseconds)
    esp_sleep_enable_timer_wakeup(sleepDurationMs * 1000);

    // Configure GPIO wake-up using the platform-appropriate API.
    _configureGpioWakeup(wakeUpPin);

    DebugService::getInstance().debugPrint("DeepSleepService: Wake-up configured - Timer: ");
    DebugService::getInstance().debugPrint(String(sleepDurationMs));
    DebugService::getInstance().debugPrint("ms, GPIO: ");
    DebugService::getInstance().debugPrintln(String(wakeUpPin));
  }

  /**
   * @brief Configures button-only wake-up (no timer).
   *
   * This is useful when the device has no WiFi credentials and cannot perform
   * periodic sensor uploads. The device will only wake on a button press.
   *
   * @param wakeUpPin GPIO pin connected to the button for wake-up.
   */
  void configureWakeUpButtonOnly(gpio_num_t wakeUpPin) {
    _wakeUpPin = wakeUpPin;
    _sleepDurationMs = 0;

    _configureGpioWakeup(wakeUpPin);

    DebugService::getInstance().debugPrint("DeepSleepService: Wake-up configured - Button only on GPIO: ");
    DebugService::getInstance().debugPrintln(String(wakeUpPin));
  }

  /**
   * @brief Puts the device into deep sleep.
   *
   * Call this after completing sensor readings and data uploads. The device
   * will not return from this call until a configured wake-up source fires.
   */
  void enterDeepSleep() {
    DebugService::getInstance().debugPrintln("DeepSleepService: Entering deep sleep...");
    esp_deep_sleep_start();
  }

private:
  uint64_t _sleepDurationMs;
  gpio_num_t _wakeUpPin;

  DeepSleepService() : _sleepDurationMs(0), _wakeUpPin(GPIO_NUM_MAX) {}

  /**
   * @brief Configures GPIO-based deep sleep wakeup using the correct API for
   * the current ESP32 variant.
   *
   * On the ESP32-C3, uses esp_deep_sleep_enable_gpio_wakeup() which operates
   * on the digital GPIO domain. On other variants, uses EXT1 wakeup through
   * the RTC GPIO subsystem.
   *
   * @param pin The GPIO pin to configure as a wake-up source (active-low).
   */
  void _configureGpioWakeup(gpio_num_t pin) {
    // Enable pull-up on the wakeup pin to prevent floating during sleep.
    gpio_pullup_en(pin);
    gpio_pulldown_dis(pin);

#if defined(CONFIG_IDF_TARGET_ESP32C3)
    // The C3 uses the deep sleep GPIO wakeup API. The pin mask indicates
    // which GPIOs can trigger wakeup, and the mode specifies the level.
    uint64_t wakeupMask = 1ULL << pin;
    esp_deep_sleep_enable_gpio_wakeup(wakeupMask, ESP_GPIO_WAKEUP_GPIO_LOW);
    DebugService::getInstance().debugPrintln("DeepSleepService: GPIO wakeup configured (C3 deep sleep GPIO API)");
#else
    // For original ESP32, S2, S3: use RTC GPIO with EXT1 wakeup.
    esp_err_t rtc_result = rtc_gpio_pullup_en(pin);
    if (rtc_result == ESP_OK) {
      rtc_gpio_pulldown_dis(pin);
      DebugService::getInstance().debugPrintln("DeepSleepService: RTC pull-up enabled on wakeup pin");
    } else {
      DebugService::getInstance().debugPrintln("DeepSleepService: RTC pull-up not supported on this pin, using regular pull-up");
    }

    rtc_gpio_isolate(pin);

    uint64_t wakeupMask = 1ULL << pin;
    esp_sleep_enable_ext1_wakeup(wakeupMask, ESP_EXT1_WAKEUP_ANY_LOW);
    DebugService::getInstance().debugPrintln("DeepSleepService: EXT1 wakeup configured");
#endif
  }
};

#endif // DEEP_SLEEP_SERVICE_H
