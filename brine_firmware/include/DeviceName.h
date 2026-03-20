#ifndef DEVICENAME_H
#define DEVICENAME_H

#include <Arduino.h>
#include <WiFi.h>

/**
 * @class DeviceName
 * @brief Utility class for managing device names.
 *
 * This class provides a static method to retrieve the device name,
 * which is constructed using the word "Brine" followed by the last 4 digits
 * of the device's MAC address. It utilizes the WiFi module to access the MAC address.
 */
class DeviceName {
public:
  /**
   * @brief Retrieves the name of the device.
   *
   * This function retrieves the name of the device. The name is the word,
   * "Brine" followed by the last 4 digits of the MAC address of the device.
   *
   * @return The name of the device.
   */
  static String getDeviceName() {
    // Set the name of the device, which is the word "Brine" followed by the
    // last 4 digits of the MAC address.
    String macAddress = WiFi.macAddress();
    String deviceName = "Brine " + macAddress.substring(9, 14);
    deviceName.replace(":", "");

    return deviceName;
  }
};

#endif // DEVICENAME_H