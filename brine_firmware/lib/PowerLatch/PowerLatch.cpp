#include "PowerLatch.h"

/**
 * @brief Construct a new PowerLatch object.
 *
 * Private constructor enforcing the singleton pattern. Pin assignments are
 * set from build-time defines (PWR_KILL_PIN, PWR_INT_PIN).
 */
PowerLatch::PowerLatch() {}

/**
 * @brief Initializes the power latch GPIO interface.
 *
 * Configures PWR_KILL as a digital output held LOW (keeping the LTC2954
 * latched on) and PWR_INT as an input with an internal pull-up. If a
 * non-null ISR is provided, it is attached to PWR_INT on the falling edge
 * so the firmware is notified immediately when the user presses the power
 * button.
 *
 * This method should be called once during setup(), after the serial debug
 * service is available.
 *
 * @param shutdownISR Optional interrupt handler invoked when PWR_INT falls.
 *   Pass nullptr to rely on polling via isShutdownRequested() instead.
 * @return true if initialization succeeded.
 */
bool PowerLatch::begin(void (*shutdownISR)()) {
  _debugService.debugPrintln(
      "PowerLatch: Initializing (KILL=" + String(_killPin) +
      ", INT=" + String(_intPin) + ")");

  // PWR_KILL must be LOW for the LTC2954 to keep its output enabled. Driving
  // it HIGH commands the latch to disconnect the power rail.
  pinMode(_killPin, OUTPUT);
  digitalWrite(_killPin, LOW);

  // The LTC2954 drives PWR_INT LOW when the user presses the power button.
  // The internal pull-up keeps the line HIGH during normal operation.
  pinMode(_intPin, INPUT_PULLUP);

  // Attach an interrupt on the falling edge if a handler was provided.
  if (shutdownISR != nullptr) {
    attachInterrupt(digitalPinToInterrupt(_intPin), shutdownISR, FALLING);
    _debugService.debugPrintln("PowerLatch: Interrupt attached on PWR_INT.");
  }

  _initialized = true;
  _debugService.debugPrintln("PowerLatch: Initialized.");
  return true;
}

/**
 * @brief Polls the PWR_INT pin to determine if a shutdown was requested.
 *
 * Returns true when the LTC2954 is asserting PWR_INT LOW, indicating the
 * user pressed the power button. This provides a cooperative polling
 * alternative to the interrupt-driven approach, useful in contexts where
 * the ISR flag may have been missed or as a secondary check.
 *
 * @return true if PWR_INT is currently asserted (active-low), false otherwise.
 */
bool PowerLatch::isShutdownRequested() {
  if (!_initialized) {
    return false;
  }

  return digitalRead(_intPin) == LOW;
}

/**
 * @brief Commands the LTC2954 to disconnect the main power rail.
 *
 * Drives PWR_KILL HIGH, which tells the LTC2954 to de-latch its output
 * and remove power from the system. Call this only after all graceful
 * shutdown work is complete (state saved, data uploaded, peripherals
 * disabled).
 *
 * A 500ms delay follows the assertion to allow the latch to respond. If
 * execution continues past this method, the LTC2954 is likely not present
 * (common during bench testing without the full power circuit populated).
 */
void PowerLatch::shutdown() {
  _debugService.debugPrintln("PowerLatch: Asserting PWR_KILL HIGH. Power will be removed.");

  digitalWrite(_killPin, HIGH);

  // Allow time for the LTC2954 to respond and disconnect the rail.
  delay(500);

  // If execution reaches here, the latch circuit did not cut power. This can
  // happen during bench testing without the LTC2954 populated.
  _debugService.debugPrintln("PowerLatch: PWR_KILL asserted but power remains. Latch may not be present.");
}
