# Deep Sleep Handling

The Brine monitor is an IoT device designed to monitor the salt level in a water softener and communicate this information to a connected application. A crucial aspect of its design is the efficient use of battery power, achieved through the implementation of deep sleep functionality. This document outlines how the firmware manages deep sleep to extend battery life.

## Overview

Under normal operation, the Brine monitor enters a deep sleep state for 24 hours. Upon waking, it performs the following sequence of operations:

1. Measures the salt level using a time-of-flight distance sensor.
2. Connects to WiFi using pre-configured credentials obtained from the provisioning process.
3. Sends the measured salt level and battery level information to Firebase.
4. Re-enters deep sleep for another 24-hour cycle.

Additionally, the device supports a setup mode activated by pressing a physical button. This mode lasts for three minutes, allowing for device provisioning before returning to the normal operation cycle.

## Deep Sleep Configuration

### Sleep Duration

The firmware defines a sleep duration of 24 hours (86400 seconds) using the TIME_TO_SLEEP constant. This value is adjustable and is crucial for balancing measurement frequency with battery conservation.

### Wakeup Sources

The ESP32's deep sleep capabilities are utilized to reduce power consumption to a minimum. Wakeup from deep sleep is configured to occur through two primary sources:

- **Timer Wakeup**: After the defined sleep duration elapses, the ESP32 automatically wakes up to perform its operations.
- **GPIO Wakeup**: Pressing the setup button triggers a wakeup event, allowing the device to enter setup mode for provisioning.

## Deep Sleep Implementation

### Entering Deep Sleep

Upon completing its tasks (measurement, data transmission), the device prepares to enter deep sleep:

1. **GPIO Wakeup Configuration**: The firmware configures the GPIO pin connected to the setup button as a wakeup source. This setup ensures the device can exit sleep mode if the button is pressed.
2. **Timer Wakeup Configuration**: The sleep duration is set, taking into account whether the device is in debug mode. In debug mode, a shorter sleep duration (10 seconds) is used for testing purposes.
3. **Execution of Deep Sleep**: The device enters deep sleep mode, significantly reducing power consumption.

### Wakeup Handling

Upon waking from deep sleep, the device checks the wakeup source:

- **Timer Wakeup**: The device proceeds with its measurement and data transmission tasks before re-entering deep sleep.
- **GPIO Wakeup (Button Press)**: The device enters setup mode, indicated by the activation of the NeoPixel LED and the availability for provisioning. After three minutes or upon completion of provisioning, the device resumes normal operation.

## Debug Mode

The firmware includes a debug mode (`DEBUG` flag) that facilitates testing and troubleshooting:

- **Serial Output**: When enabled, debug messages are printed to the serial console to provide insights into the device's operation and wakeup reasons.
- **Reduced Sleep Duration**: For rapid testing, the sleep duration is significantly reduced in debug mode.

## Conclusion

The Brine monitor's firmware efficiently manages deep sleep to extend battery life while ensuring regular measurements and connectivity. By leveraging the ESP32's deep sleep features, the device maintains a balance between operational functionality and power conservation, making it an effective solution for monitoring water softener salt levels in an IoT context.