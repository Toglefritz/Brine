#ifndef POWER_LATCH_H
#define POWER_LATCH_H

#include <Arduino.h>
#include "../../include/DebugService.h"

// Default pin assignments, overridable via build flags.
#ifndef PWR_KILL_PIN
#define PWR_KILL_PIN 20
#endif

#ifndef PWR_INT_PIN
#define PWR_INT_PIN 2
#endif

/**
 * @class PowerLatch
 * @brief Controls the LTC2954 power latch circuit.
 *
 * This singleton service manages the two-pin interface between the ESP32 and
 * the LTC2954 pushbutton power controller:
 *
 * - PWR_KILL (output): Driven HIGH to command the LTC2954 to disconnect the
 *   main power rail. The firmware asserts this pin after completing any
 *   graceful shutdown work (saving state, uploading data, etc.).
 *
 * - PWR_INT (input, active-low): The LTC2954 asserts this pin LOW when the
 *   user presses the power button. The firmware monitors this signal to
 *   initiate a graceful shutdown sequence before power is removed.
 *
 * The service supports both polling and interrupt-driven detection of the
 * shutdown request. Callers register a shutdown handler via begin(), and the
 * main loop can also poll isShutdownRequested() for cooperative checking.
 */
class PowerLatch {
public:
  /**
   * @brief Returns the singleton PowerLatch instance.
   */
  static PowerLatch &getInstance() {
    static PowerLatch instance;
    return instance;
  }

  /**
   * @brief Initializes the power latch GPIO pins.
   *
   * Configures PWR_KILL as an output (initially LOW to keep power on) and
   * PWR_INT as an input with an internal pull-up. If a non-null interrupt
   * handler is provided, it is attached to PWR_INT on the falling edge so
   * the firmware is notified immediately when the user presses the power
   * button.
   *
   * @param shutdownISR Optional ISR to invoke when PWR_INT falls. Pass
   *   nullptr to rely on polling via isShutdownRequested() instead.
   * @return true if initialization succeeded.
   */
  bool begin(void (*shutdownISR)() = nullptr);

  /**
   * @brief Returns true if the LTC2954 has asserted PWR_INT (active-low).
   *
   * This is a non-blocking poll that reads the current pin state. It can be
   * called from the main loop as a cooperative check alongside or instead of
   * the interrupt-driven approach.
   */
  bool isShutdownRequested();

  /**
   * @brief Asserts PWR_KILL HIGH, commanding the LTC2954 to cut power.
   *
   * Call this only after all graceful shutdown work is complete (state saved,
   * data uploaded, peripherals disabled). Once asserted, the LTC2954 will
   * disconnect the power rail and the microcontroller will lose power.
   *
   * The method includes a short delay after asserting the pin to allow the
   * latch to respond. If power is not cut (e.g. during development without
   * the latch circuit populated), execution continues past this call.
   */
  void shutdown();

  /**
   * @brief Returns the GPIO pin number used for PWR_KILL.
   */
  uint8_t getKillPin() const { return _killPin; }

  /**
   * @brief Returns the GPIO pin number used for PWR_INT.
   */
  uint8_t getIntPin() const { return _intPin; }

private:
  PowerLatch();

  uint8_t _killPin = PWR_KILL_PIN;
  uint8_t _intPin = PWR_INT_PIN;
  bool _initialized = false;

  DebugService &_debugService = DebugService::getInstance();

  PowerLatch(const PowerLatch &) = delete;
  PowerLatch &operator=(const PowerLatch &) = delete;
};

#endif // POWER_LATCH_H
