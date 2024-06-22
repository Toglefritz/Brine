#ifndef BLEAPIHANDLER_H
#define BLEAPIHANDLER_H

#include "DebugService.h"
#include <ArduinoJson.h>
#include <WiFi.h>
#include "DeviceName.h"
#include <set>
#include <string>

/**
 * @class BLEApiHandler
 * @brief A class to handle JSON-based API commands over BLE.
 *
 * The BLEApiHandler class is responsible for parsing and processing JSON commands
 * received over Bluetooth Low Energy (BLE) and generating appropriate JSON responses.
 * This class enables the IoT device to communicate with a central device using a
 * structured JSON-based protocol, allowing for flexible and extensible command handling.
 *
 * @details
 * The BLEApiHandler class processes incoming JSON commands and generates responses
 * based on the requested operations. The primary function of the class is to handle
 * specific commands and return JSON responses that the central device can interpret.
 *
 * Example JSON command format:
 * @code
 * {
 *     "command": "get_device_id"
 * }
 * @endcode
 *
 * Example JSON response format:
 * @code
 * {
 *     "response": "device_id",
 *     "device_id": "Brine-1234"
 * }
 * @endcode
 *
 * In the event of an error or an unknown command, the response will indicate the error:
 * @code
 * {
 *     "response": "error",
 *     "message": "Unknown command"
 * }
 * @endcode
 */
class BLEApiHandler {
public:
  BLEApiHandler() {}

  /**
   * @brief Handles incoming JSON command requests.
   *
   * @param jsonCommand The JSON command string received from the central device.
   * @return String The JSON response string to be sent back to the central device.
   */
  String handleCommand(const String &jsonCommand) {
    // Parse the JSON command
    JsonDocument doc;
    DeserializationError error = deserializeJson(doc, jsonCommand);

    if (error) {
      DebugService::getInstance().debugPrintln("Failed to parse JSON command");

      return createErrorResponse("Invalid JSON");
    }

    // Extract the command
    const char *command = doc["command"];

    // The command, "get_device_id," returns the device ID of the IoT device.
    if (strcmp(command, "get_device_id") == 0) {
      return handleGetDeviceId();
    }
    // The command, "scan," returns a list of available WiFi networks.
    else if (strcmp(command, "scan") == 0) {
      return handleScanWifiNetworks();
    }
    // The command "wifi_connect" provides the SSID and password for a network to which the device should connect
    // in the parameters provided with this command. The parameters use the "ssid" and "password" keys.
    else if (strcmp(command, "wifi_connect") == 0) {
      // Get the parameters for the WiFi connection
      JsonObject parameters = doc["parameters"].as<JsonObject>();

      const char *ssid = parameters["ssid"];
      const char *password = parameters["password"];

      return handleWifiConnect(ssid, password);
    }
    // The command is not recognized
    else {
      return createErrorResponse("Unknown command");
    }
  }

private:
  /**
   * @brief Handles the 'get_device_id' command.
   *
   * @return String The JSON response string containing the device ID.
   */
  String handleGetDeviceId() {
    JsonDocument responseDoc;
    responseDoc["response"] = "device_id";
    responseDoc["device_id"] = DEVICE_ID; // Use the defined DEVICE_ID

    String jsonResponse;

    serializeJson(responseDoc, jsonResponse);

    DebugService::getInstance().debugPrint("Returning response with device ID, ");
    DebugService::getInstance().debugPrintln(jsonResponse);

    return jsonResponse;
  }

  /**
   * @brief Scans for WiFi networks and returns a list of networks as a JSON string.
   *
   * This method scans for available WiFi networks and constructs a JSON array
   * with objects representing each network. Each object includes the SSID and RSSI
   * (signal strength) of the network.
   *
   * @return String The JSON response string containing the list of WiFi networks.
   */
  String handleScanWifiNetworks() {
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

    // Create a JSON response with a response" key set to "scan" and an array of networks as the value of the "networks"
    // key.
    JsonDocument responseDoc;

    responseDoc["response"] = "scan";
    responseDoc["networks"] = responseArray;

    String jsonResponse;
    serializeJson(responseDoc, jsonResponse);

    DebugService::getInstance().debugPrint("Returning WiFi scan results, ");
    DebugService::getInstance().debugPrintln(jsonResponse);

    return jsonResponse;
  }

  /**
   * @brief Connects to a WiFi network using the provided SSID and password.
   * 
   * This method attempts to connect to the specified WiFi network using the provided SSID and password. The method
   * waits for the connection to be established and returns a JSON response indicating the connection status. The
   * connection process includes a timeout to prevent the device from waiting indefinitely for a connection. If
   * the connection is successful, the response includes the SSID of the connected network. If the connection fails,
   * the response includes an error message indicating the reason for the failure.
   *
   * @param ssid The SSID of the WiFi network to connect to.
   * @param password The password for the WiFi network.
   * @return String The JSON response string indicating the connection status.
   */
  String handleWifiConnect(const char *ssid, const char *password) {
    DebugService::getInstance().debugPrint("Connecting to WiFi network: ");
    DebugService::getInstance().debugPrintln(ssid);

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

    // Check if the connection was successful
    if (WiFi.status() == WL_CONNECTED) {
      DebugService::getInstance().debugPrint("Connected to WiFi network: ");
      DebugService::getInstance().debugPrintln(ssid);

      // Create a JSON response indicating successful connection.
      JsonDocument responseDoc;
      responseDoc["response"] = "wifi_connected";
      responseDoc["ssid"] = ssid;

      String jsonResponse;
      serializeJson(responseDoc, jsonResponse);

      return jsonResponse;
    } else {
      DebugService::getInstance().debugPrint("Failed to connect to WiFi network: ");
      DebugService::getInstance().debugPrintln(ssid);

      // Create a JSON response indicating the reason for the failure.
      JsonDocument errorResponseDoc;
      errorResponseDoc["response"] = "wifi_connect_error";

      if (WiFi.status() == WL_NO_SSID_AVAIL) {
        errorResponseDoc["message"] = "SSID not found";
      } else if (WiFi.status() == WL_CONNECT_FAILED) {
        errorResponseDoc["message"] = "Connection failed";
      } else {
        errorResponseDoc["message"] = "Unknown error";
      }

      String errorResponse;
      serializeJson(errorResponseDoc, errorResponse);

      return errorResponse;
    }
  }

  /**
   * @brief Creates an error response JSON string.
   *
   * @param errorMessage The error message to include in the response.
   * @return String The JSON error response string.
   */
  String createErrorResponse(const char *errorMessage) {
    JsonDocument errorDoc;
    errorDoc["response"] = "error";
    errorDoc["message"] = errorMessage;

    String errorResponse;
    serializeJson(errorDoc, errorResponse);
    
    return errorResponse;
  }
};

#endif // BLEAPIHANDLER_H