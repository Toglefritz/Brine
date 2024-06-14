#ifndef BLEAPIHANDLER_H
#define BLEAPIHANDLER_H

#include "DebugService.h"
#include <ArduinoJson.h>

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
    StaticJsonDocument<256> doc;
    DeserializationError error = deserializeJson(doc, jsonCommand);

    if (error) {
      DebugService::getInstance().debugPrintln("Failed to parse JSON command");

      return createErrorResponse("Invalid JSON");
    }

    // Extract the command
    const char *command = doc["command"];

    // The command, "get_device_id", returns the device ID of the IoT device.
    if (strcmp(command, "get_device_id") == 0) {
      return handleGetDeviceId();
    }

    // Handle unknown command
    return createErrorResponse("Unknown command");
  }

private:
  /**
   * @brief Handles the 'get_device_id' command.
   *
   * @return String The JSON response string containing the device ID.
   */
  String handleGetDeviceId() {
    StaticJsonDocument<256> responseDoc;
    responseDoc["response"] = "device_id";
    responseDoc["device_id"] = DEVICE_ID; // Use the defined DEVICE_ID

    String jsonResponse;
    serializeJson(responseDoc, jsonResponse);

    return jsonResponse;
  }

  /**
   * @brief Creates an error response JSON string.
   *
   * @param errorMessage The error message to include in the response.
   * @return String The JSON error response string.
   */
  String createErrorResponse(const char *errorMessage) {
    StaticJsonDocument<256> errorDoc;
    errorDoc["response"] = "error";
    errorDoc["message"] = errorMessage;

    String errorResponse;
    serializeJson(errorDoc, errorResponse);
    return errorResponse;
  }
};

#endif // BLEAPIHANDLER_H