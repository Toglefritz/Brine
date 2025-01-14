#ifndef BLEAPIHANDLER_H
#define BLEAPIHANDLER_H

#include "DebugService.h"
#include "FirebaseService.h"
#include "WiFiService.h"
#include <ArduinoJson.h>
#include <NVSService.h>
#include <set>
#include <string>

/**
 * @class BLEApiHandler
 * @brief A class to handle JSON-based API commands over BLE.
 *
 * The BLEApiHandler class is responsible for parsing and processing JSON commands received over Bluetooth Low Energy
 * (BLE) and generating appropriate JSON responses. This class enables the IoT device to communicate with a central
 * device using a structured JSON-based protocol, allowing for flexible and extensible command handling.
 *
 * Depending upon the command received, the BLEApiHandler class can perform various operations such as retrieving the
 * device ID, scanning for available WiFi networks, connecting to a specific WiFi network, and more. To accomplish
 * these tasks, this class interacts with different service classes such as `WiFiService`, `FirebaseService`, and
 * 'DeviceName' to perform the required operations.
 *
 * @details
 * The `BLEApiHandler` class processes incoming JSON commands and generates responses based on the requested operations.
 * The primary function of the class is to handle specific commands and return JSON responses that the central device
 * can interpret.
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
private:
  /**
   * @brief Pointer to the WiFiService instance.
   *
   * The WiFiService instance is used to interact with the WiFi module on the ESP32. The WiFiService class provides
   * methods for scanning for available networks and connecting to a specific network.
   */
  WiFiService *wifiService;

  /**
   * @brief Pointer to the FirebaseService instance.
   *
   * The FirebaseService instance is used to interact with the Firebase backend. The FirebaseService class provides
   * methods for uploading sensor data to Firebase using HTTP POST requests.
   */
  FirebaseService *firebaseService;

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
    // The command "psk_transfer," is used by the mobile app to provide a pre-shared key to the IoT device that it 
    // will use later in calls to the backend service.
    else if (strcmp(command, "psk_transfer") == 0) {
      // Get the parameters from the command.
      JsonObject parameters = doc["parameters"].as<JsonObject>();

      // Get the PSKfrom the parameters.
      const char *psk = parameters["key"];

      return handlePskProvided(psk);
    }
    // The command, "scan," returns a list of available WiFi networks.
    else if (strcmp(command, "scan") == 0) {
      return handleScanWifiNetworks();
    }
    // The command "wifi_connect" provides the SSID and password for a network to which the device should connect
    // in the parameters provided with this command. The parameters use the "ssid" and "password" keys.
    else if (strcmp(command, "wifi_connect") == 0) {
      // Get the parameters for the WiFi connection from the command.
      JsonObject parameters = doc["parameters"].as<JsonObject>();

      const char *ssid = parameters["ssid"];
      const char *password = parameters["password"];

      return handleWifiConnect(ssid, password);
    }
    // The command "complete_provisioning" indicates that the provisioning process is complete.
    else if (strcmp(command, "complete_provisioning") == 0) {
      return handleCompleteProvisioning();
    }
    // The command is not recognized
    else {
      return createErrorResponse("Unknown command");
    }
  }

  /**
   * @brief Sets a callback function to handle the provisioning completion event.
   */
  void setProvisioningCompleteCallback(std::function<void()> callback) { provisioningCompleteCallback = callback; }

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
   * @brief Stores a pre-shared key provided by the client into NVS.
   *
   * This IoT device interacts with a cloud backend service. Those interactions require authentication in the form
   * of HMAC signatures generated from a pre-shared key. That pre-shared key is transferred from the mobile
   * app as part of the Brine provisioning process.
   *
   * This function handles the transfer of PSKs from the client device over Bluetooth. The IoT device will save these 
   * keys into NVS for later use.
   *
   * @return String The JSON response containing a confirmation of the command.
   */
  String handlePskProvided(const char *psk) {
    // Get the instance of the NVSServices singleton.
    NVSService &nvsService = NVSService::getInstance();

    // Create a JSON document to store the PSK.
    JsonDocument doc;
    doc["psk"] = psk;

    // Save the JSON document under the key "preSharedKey"
    bool saveResult = nvsService.saveJSON("preSharedKey", doc);

    // If saving the token to NVS failed, return an error response.
    if (!saveResult) {
      return createErrorResponse("Failed to save refresh token");
    }
    // Otherwise, if saving the token was successful, return a success response.
    else {
      JsonDocument responseDoc;
      responseDoc["response"] = "psk_saved";

      String jsonResponse;
      serializeJson(responseDoc, jsonResponse);

      return jsonResponse;
    }
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
    // Get a list of available WiFi networks as a JSON array.
    JsonDocument responseArray = WiFiService::scanForNetworks();

    // Create a JSON response object with the array of networks.
    JsonDocument responseDoc;
    responseDoc["response"] = "scan";
    responseDoc["networks"] = responseArray;

    // Serialize the JSON response to a string.
    String jsonResponse;
    serializeJson(responseDoc, jsonResponse);

    DebugService::getInstance().debugPrint("Returning WiFi scan results, ");
    DebugService::getInstance().debugPrintln(jsonResponse);

    // Return the JSON response string.
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

    // Connect to the specified WiFi network.
    bool connected = WiFiService::connectToNetwork(ssid, password);

    // Check if the connection was successful
    if (connected) {
      DebugService::getInstance().debugPrint("Connected to WiFi network: ");
      DebugService::getInstance().debugPrintln(ssid);

      // Save the SSID and password to NVS so they can be used to reconnect to WiFi after a reboot.
      // Initialize NVSService with the "wifi" namespace.
      if (!NVSService::getInstance().begin("wifi")) {
        DebugService::getInstance().debugPrintln("NVS Service initialization failed.");
        // TODO Handle initialization failure
      } else {
        DebugService::getInstance().debugPrintln("NVS Service initialized successfully.");

        // Create a JSON document to store the WiFi credentials.
        JsonDocument wifiCredentialsDoc;
        wifiCredentialsDoc["ssid"] = ssid;
        wifiCredentialsDoc["password"] = password;

        // Save the WiFi credentials to NVS under the key, "wifiCredentials".
        if (!NVSService::getInstance().saveJSON("wifiCredentials", wifiCredentialsDoc)) {
          DebugService::getInstance().debugPrintln("Failed to save WiFi credentials to NVS.");
          // TODO Handle save failure
        } else {
          DebugService::getInstance().debugPrintln("WiFi credentials saved to NVS.");
        }
      }

      // Create a JSON response indicating successful connection.
      JsonDocument responseDoc;
      responseDoc["response"] = "wifi_connected";
      responseDoc["ssid"] = ssid;

      String jsonResponse;
      serializeJson(responseDoc, jsonResponse);

      return jsonResponse;
    }
    // If the connection failed, return an error response.
    else {
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
   * @brief A callback function to handle the completion of the provisioning process.
   */
  std::function<void()> provisioningCompleteCallback;

  /**
   * @brief Concludes the provisioning process by sending the salt and battery levels to Firebase and then ending
   * Bluetooth communication.
   *
   * This method is called when the client indicates to the Brine device that all setup steps are complete.
   */
  String handleCompleteProvisioning() {
    DebugService::getInstance().debugPrint("Completing provisioning process");

    // Check if the connection was successful
    try {
      // Create a JSON response indicating successful connection.
      JsonDocument responseDoc;
      responseDoc["response"] = "provisioning_complete";

      String jsonResponse;
      serializeJson(responseDoc, jsonResponse);

      // Call the provisioning complete callback function
      provisioningCompleteCallback();

      DebugService::getInstance().debugPrint("Provisioning process complete");

      return jsonResponse;
    }
    // If the connection failed, return an error response.
    catch (const std::exception &e) {
      DebugService::getInstance().debugPrint("Failed to complete provisioning process: ");
      DebugService::getInstance().debugPrintln(e.what());

      // Create a JSON response indicating the reason for the failure.
      JsonDocument errorResponseDoc;
      errorResponseDoc["response"] = "complete_provisioning_error";
      errorResponseDoc["message"] = e.what();

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