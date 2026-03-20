#include "DeviceName.h"
#include <ArduinoJson.h>
#include <WiFi.h>
#include <set>
#include <string>

/**
 * @class WiFiService
 * @brief Handles all WiFi-related functionalities including scanning for networks and connecting to a network.
 *
 * This class is designed to encapsulate the WiFi management functionalities such as scanning for available WiFi
 * networks, connecting to a WiFi network with given credentials, and managing WiFi connection states. It provides a
 * high-level interface for WiFi operations for other parts of the firmware.
 */
class WiFiService {
public:
  /**
   * @brief Initiates a scan for available WiFi networks.
   *
   * This method triggers a scan to find all available WiFi networks in the vicinity. Once the scan is initiated,
   * it operates asynchronously, and the results can be retrieved using the `getScannedNetworks` method. The scan
   * results will include information such as the SSID (network name), signal strength (RSSI), and encryption type
   * for each detected network.
   */
  static JsonDocument scanForNetworks() {
    int numberOfNetworks = WiFi.scanNetworks();

    JsonDocument networksDoc;
    JsonArray responseArray = networksDoc.to<JsonArray>();

    // Set to store unique SSIDs
    std::set<String> uniqueSSIDs;

    for (int i = 0; i < numberOfNetworks; i++) {
      String ssid = WiFi.SSID(i);

      // Check if the SSID is already in the set
      if (uniqueSSIDs.find(ssid) == uniqueSSIDs.end()) {
        // Add the new SSID to the set
        uniqueSSIDs.insert(ssid);

        // Add the new network to the JSON array
        JsonObject networkObj = responseArray.add<JsonObject>();
        networkObj["ssid"] = ssid;
        networkObj["rssi"] = WiFi.RSSI(i);
      }
    }

    return networksDoc;
  }

/**
 * @brief Attempts to connect to a specified WiFi network using the provided SSID and password.
 *
 * This method initiates a connection attempt to the WiFi network identified by the given SSID and password. It blocks 
 * until the connection attempt is either successful or fails, returning a boolean value to indicate the outcome. 
 * 
 * @param ssid The SSID of the WiFi network to connect to.
 * @param password The password of the WiFi network. For open networks, this can be an empty string.
 *
 * @return true if the connection was successful, false otherwise.
 */
  static bool connectToNetwork(const char *ssid, const char *password) {
    // Set the hostname for the Brine device.
    String deviceName = DeviceName::getDeviceName();
    // Replace the spaces in the device name with underscores.
    deviceName.replace(" ", "_");
    WiFi.setHostname(deviceName.c_str());

    // Connect to the specified WiFi network
    WiFi.begin(ssid, password);

    // Wait for the connection to be established
    int timeout = 10; // Timeout in seconds
    while (WiFi.status() != WL_CONNECTED && timeout > 0) {
      delay(1000);
      timeout--;
    }

    // Check if the connection was successful.
    if (WiFi.status() == WL_CONNECTED) {
      return true;
    } else {
      return false;
    }
  }
};