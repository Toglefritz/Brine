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
 * @brief A class to handle JSON-based API commands over BLE with deferred execution.
 *
 * This class uses a command queue pattern to minimize work done in BLE callbacks (BTC_TASK context).
 * Commands are parsed and queued in the BLE callback, then processed in the main loop where
 * there's sufficient stack space for heavy operations like NVS writes and WiFi operations.
 */
class BLEApiHandler {
public:
  // Command types that can be queued
  enum class CommandType {
    NONE,
    GET_DEVICE_ID,
    PSK_TRANSFER,
    WIFI_SCAN,
    WIFI_CONNECT,
    COMPLETE_PROVISIONING
  };

  // Structure to hold command data
  struct PendingCommand {
    CommandType type = CommandType::NONE;
    String param1;  // Used for PSK, SSID, etc.
    String param2;  // Used for WiFi password
  };

private:
  // Pending command to be processed in main loop
  PendingCommand pendingCommand;
  
  // Flag indicating a command is ready to process
  volatile bool commandReady = false;

public:
  BLEApiHandler() {}

  /**
   * @brief Parses incoming JSON command and queues it for processing.
   * 
   * This method runs in BLE callback (BTC_TASK) context, so it does minimal work:
   * - Parse JSON to identify command type
   * - Extract and store parameters
   * - Return empty string (response sent later from main loop)
   *
   * @param jsonCommand The JSON command string received from the central device.
   * @return String Empty string - actual response sent from main loop after processing.
   */
  String handleCommand(const String &jsonCommand) {
    // Parse the JSON command (lightweight operation)
    JsonDocument doc;
    DeserializationError error = deserializeJson(doc, jsonCommand);

    if (error) {
      DebugService::getInstance().debugPrintln("Failed to parse JSON command");
      // For parse errors, we can return immediately since no heavy processing needed
      return createErrorResponse("Invalid JSON");
    }

    // Extract the command type
    const char *command = doc["command"];

    // Queue the command based on type
    if (strcmp(command, "get_device_id") == 0) {
      pendingCommand.type = CommandType::GET_DEVICE_ID;
      commandReady = true;
    }
    else if (strcmp(command, "psk_transfer") == 0) {
      JsonObject parameters = doc["parameters"].as<JsonObject>();
      const char *psk = parameters["psk"];
      
      DebugService::getInstance().debugPrint("Received PSK from mobile app: ");
      DebugService::getInstance().debugPrintln(psk);
      
      pendingCommand.type = CommandType::PSK_TRANSFER;
      pendingCommand.param1 = String(psk);
      commandReady = true;
    }
    else if (strcmp(command, "scan") == 0) {
      pendingCommand.type = CommandType::WIFI_SCAN;
      commandReady = true;
    }
    else if (strcmp(command, "wifi_connect") == 0) {
      JsonObject parameters = doc["parameters"].as<JsonObject>();
      const char *ssid = parameters["ssid"];
      const char *password = parameters["password"];
      
      pendingCommand.type = CommandType::WIFI_CONNECT;
      pendingCommand.param1 = String(ssid);
      pendingCommand.param2 = String(password);
      commandReady = true;
    }
    else if (strcmp(command, "complete_provisioning") == 0) {
      pendingCommand.type = CommandType::COMPLETE_PROVISIONING;
      commandReady = true;
    }
    else {
      // Unknown command - can return error immediately
      return createErrorResponse("Unknown command");
    }

    // Return empty string - response will be sent from main loop
    return "";
  }

  /**
   * @brief Checks if a command is ready to process and executes it.
   * 
   * This method should be called from the main loop. It has access to the full
   * main task stack (8KB) for heavy operations.
   * 
   * @return String The JSON response to send back via BLE, or empty if no command ready.
   */
  String processCommand() {
    if (!commandReady) {
      return "";
    }

    // Clear the flag
    commandReady = false;

    // Process the command based on type
    String response;
    switch (pendingCommand.type) {
      case CommandType::GET_DEVICE_ID:
        response = handleGetDeviceId();
        break;
        
      case CommandType::PSK_TRANSFER:
        response = handlePskProvided(pendingCommand.param1.c_str());
        break;
        
      case CommandType::WIFI_SCAN:
        response = handleScanWifiNetworks();
        break;
        
      case CommandType::WIFI_CONNECT:
        response = handleWifiConnect(pendingCommand.param1.c_str(), pendingCommand.param2.c_str());
        break;
        
      case CommandType::COMPLETE_PROVISIONING:
        response = handleCompleteProvisioning();
        break;
        
      default:
        response = createErrorResponse("Unknown command type");
        break;
    }

    // Clear the command
    pendingCommand.type = CommandType::NONE;
    pendingCommand.param1 = "";
    pendingCommand.param2 = "";

    return response;
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

    // Save the PSK as a string under the key "preSharedKey"
    bool saveResult = nvsService.saveString("psk", psk);

    // If saving the PSK to NVS failed, return an error response.
    if (!saveResult) {
        return createErrorResponse("Failed to save pre-shared key");
    }

    // Otherwise, if saving the PSK was successful, return a success response.
    JsonDocument responseDoc;
    responseDoc["response"] = "psk_saved";

    String jsonResponse;
    serializeJson(responseDoc, jsonResponse);

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
   * @brief Concludes the provisioning process by sending the salt and battery levels to Firebase and then ending
   * Bluetooth communication.
   *
   * This method is called when the client indicates to the Brine device that all setup steps are complete.
   */
  String handleCompleteProvisioning() {
    DebugService::getInstance().debugPrintln("Completing provisioning process");

    // Check if the connection was successful
    try {
      // Create a JSON response indicating successful connection.
      JsonDocument responseDoc;
      responseDoc["response"] = "provisioning_complete";

      String jsonResponse;
      serializeJson(responseDoc, jsonResponse);

      DebugService::getInstance().debugPrintln("Provisioning process complete");

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