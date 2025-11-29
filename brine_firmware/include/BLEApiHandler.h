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

private:
  // Buffer for accumulating PSK chunks
  String pskBuffer = "";
  
  // Flag to indicate PSK is ready to be saved (deferred to main loop)
  bool pskReadyToSave = false;
  
  // Flag to indicate WiFi scan is requested (deferred to main loop)
  bool wifiScanRequested = false;
  
  // Pending response to be sent from main loop (to avoid stack overflow in BLE callback)
  String pendingResponse = "";

public:
  BLEApiHandler() {}
  
  /**
   * @brief Checks if PSK is ready to be saved and handles the save operation.
   * 
   * This should be called from the main loop, not from BLE callbacks.
   * Returns true if a PSK was saved and response needs to be sent.
   */
  bool processPendingPskSave() {
    if (!pskReadyToSave) {
      return false;
    }
    
    pskReadyToSave = false;
    
    // Save the PSK
    NVSService &nvsService = NVSService::getInstance();
    bool saveResult = nvsService.saveString("psk", pskBuffer.c_str());
    
    // Clear the buffer
    pskBuffer = "";
    
    return saveResult;
  }
  
  /**
   * @brief Checks if WiFi scan is requested and returns the scan results.
   * 
   * This should be called from the main loop, not from BLE callbacks.
   * Returns the JSON response string with scan results, or empty string if no scan pending.
   */
  String processPendingWifiScan() {
    if (!wifiScanRequested) {
      return "";
    }
    
    wifiScanRequested = false;
    
    // Perform WiFi scan in main loop context (plenty of stack)
    JsonDocument responseArray = WiFiService::scanForNetworks();
    
    // Create a JSON response object with the array of networks
    JsonDocument responseDoc;
    responseDoc["response"] = "scan";
    responseDoc["networks"] = responseArray;
    
    // Serialize the JSON response to a string
    String jsonResponse;
    serializeJson(responseDoc, jsonResponse);
    
    return jsonResponse;
  }
  
  /**
   * @brief Gets and clears any pending response that needs to be sent.
   * 
   * This should be called from the main loop to send responses that were
   * deferred from BLE callbacks to avoid stack overflow.
   * 
   * @return String The pending response, or empty string if none
   */
  String getPendingResponse() {
    String response = pendingResponse;
    pendingResponse = "";
    return response;
  }
  
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
    // The command "psk_chunk" is used to send PSK data in chunks to avoid stack overflow
    else if (strcmp(command, "psk_chunk") == 0) {
      JsonObject parameters = doc["parameters"].as<JsonObject>();
      const char *chunk = parameters["chunk"];
      int chunkIndex = parameters["index"] | 0;
      int totalChunks = parameters["total"] | 1;
      
      return handlePskChunk(chunk, chunkIndex, totalChunks);
    }
    // The command "psk_transfer," is used by the mobile app to provide a pre-shared key to the IoT device that it 
    // will use later in calls to the backend service.
    else if (strcmp(command, "psk_transfer") == 0) {
      // Get the parameters from the command.
      JsonObject parameters = doc["parameters"].as<JsonObject>();

      // Get the PSKfrom the parameters.
      const char *psk = parameters["psk"];

      DebugService::getInstance().debugPrint("Received PSK from mobile app: ");
      DebugService::getInstance().debugPrintln(psk);

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


private:
  /**
   * @brief Handles the 'get_device_id' command.
   *
   * Defers the response to main loop to avoid stack overflow.
   *
   * @return String Empty string (response will be sent from main loop)
   */
  String handleGetDeviceId() {
    // Build response as a single string to avoid concatenation issues
    pendingResponse = String("{\"response\":\"device_id\",\"device_id\":\"") + 
                      String(DEVICE_ID) + 
                      String("\"}");
    
    return "";
  }

  /**
   * @brief Handles receiving PSK data in chunks to avoid stack overflow.
   *
   * This method accumulates PSK chunks sent from the mobile app. When all chunks
   * are received, it sets a flag for the main loop to save the PSK.
   *
   * To minimize stack usage in the BLE callback, intermediate chunks return an empty
   * response. The final chunk sets a flag and returns empty - the actual save and
   * response happen in the main loop.
   *
   * @param chunk The PSK chunk data
   * @param chunkIndex The index of this chunk (0-based)
   * @param totalChunks The total number of chunks expected
   * @return String The JSON response (always empty - response sent from main loop)
   */
  String handlePskChunk(const char *chunk, int chunkIndex, int totalChunks) {
    // If this is the first chunk, clear the buffer
    if (chunkIndex == 0) {
      pskBuffer = "";
      pskReadyToSave = false;
    }
    
    // Append this chunk to the buffer
    if (chunk != nullptr) {
      pskBuffer += String(chunk);
    }
    
    // If this is the last chunk, set flag for main loop to save
    if (chunkIndex == totalChunks - 1) {
      pskReadyToSave = true;
    }
    
    // Always return empty string - response will be sent from main loop
    return "";
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
    DebugService::getInstance().debugPrintln("Saving PSK...");
    
    // Get the instance of the NVSServices singleton.
    NVSService &nvsService = NVSService::getInstance();

    // Save the PSK as a string under the key "psk"
    bool saveResult = nvsService.saveString("psk", psk);

    // If saving the PSK to NVS failed, return an error response.
    if (!saveResult) {
        DebugService::getInstance().debugPrintln("ERROR: Save failed");
        return "{\"response\":\"error\",\"message\":\"Failed to save PSK\"}";
    }

    DebugService::getInstance().debugPrintln("PSK saved OK");

    // Return a minimal pre-built JSON response to avoid stack overflow
    return "{\"response\":\"psk_saved\"}";
}

  /**
   * @brief Handles WiFi scan request by setting a flag for deferred processing.
   *
   * To avoid stack overflow in the BLE callback, the actual WiFi scan is deferred
   * to the main loop where there's plenty of stack space.
   *
   * @return String Empty string (response will be sent from main loop)
   */
  String handleScanWifiNetworks() {
    // Set flag for main loop to process the scan
    wifiScanRequested = true;
    
    // Return empty string - response will be sent from main loop
    return "";
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

      // Build response manually to minimize stack usage
      pendingResponse = "{\"response\":\"wifi_connected\",\"ssid\":\"";
      pendingResponse += ssid;
      pendingResponse += "\"}";

      return "";
    }
    // If the connection failed, return an error response.
    else {
      DebugService::getInstance().debugPrintln("WiFi connect failed");

      // Build error response manually to minimize stack usage
      pendingResponse = "{\"response\":\"wifi_connect_error\",\"message\":\"";
      
      if (WiFi.status() == WL_NO_SSID_AVAIL) {
        pendingResponse += "SSID not found";
      } else if (WiFi.status() == WL_CONNECT_FAILED) {
        pendingResponse += "Connection failed";
      } else {
        pendingResponse += "Unknown error";
      }
      
      pendingResponse += "\"}";

      return "";
    }
  }

  /**
   * @brief Concludes the provisioning process by sending the salt and battery levels to Firebase and then ending
   * Bluetooth communication.
   *
   * This method is called when the client indicates to the Brine device that all setup steps are complete.
   */
  String handleCompleteProvisioning() {
    // Build response manually to minimize stack usage
    pendingResponse = "{\"response\":\"provisioning_complete\"}";
    return "";
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