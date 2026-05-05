#include "PowerLatch.h"

PowerLatch::PowerLatch() {}

bool PowerLatch::begin(void (*shutdownISR)()) {
  _debugService.debugPrintln(
      "PowerLatch: Initializing (KILL=" + String(_killPin) +
      ", INT=" + String(_intPin) + ")");

  // Configure PWR_KILL as output, held LOW to keep power on.
  pinMode(_killPin, OUTPUT);
  digitalWrite(_killPin, LOW);

  // Configure PWR_INT as input with pull-up. The LTC2954 drives this pin
  // LOW when the user presses the power button.
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

bool PowerLatch::isShutdownRequested() {
  if (!_initialized) {
    return false;
  }

  // PWR_INT is active-low: LOW means the user pressed the power button.
  return digitalRead(_intPin) == LOW;
}

void PowerLatch::shutdown() {
  _debugService.debugPrintln("PowerLatch: Asserting PWR_KILL HIGH. Power will be removed.");

  digitalWrite(_killPin, HIGH);

  // Allow time for the LTC2954 to respond and disconnect the rail.
  delay(500);

  // If execution reaches here, the latch circuit did not cut power. This can
  // happen during bench testing without the LTC2954 populated.
  _debugService.debugPrintln("PowerLatch: PWR_KILL asserted but power remains. Latch may not be present.");
}
