// Filename: FirebaseService.h
#ifndef FIREBASESERVICE_H
#define FIREBASESERVICE_H

#include "DeviceConfig.h"
#include <ArduinoJson.h>
#include <CryptoService.h>
#include <HTTPClient.h>

/**
 * @class FirebaseService
 * @brief Provides static methods to send data to Firebase backend.
 *
 * This service class contains static methods for uploading sensor data to a Firebase backend.
 * It supports uploading battery life percentage and distance sensor measurements. The class
 * uses HTTP POST requests to send data to predefined Firebase endpoints.
 *
 * @note This class assumes the presence of an active internet connection.
 * PKI and cryptographic operations for secure data transmission will be added in future iterations.
 */
class FirebaseService {
public:
  /**
   * @brief Uploads both the battery life percentage and distance sensor measurement to Firebase.
   *
   * This method combines the battery life percentage and distance sensor measurement into a single JSON payload, along
   * with the device ID, and uploads it to a Firebase endpoint designed to accept multiple sensor readings.
   *
   * @param batteryLife A float representing the remaining battery life percentage.
   * @param distance A float representing the distance measured by the sensor in meters.
   *
   * @return true if the upload was successful, false otherwise.
   */
  bool uploadSensorData(float batteryLife, float distance) {
    DebugService::getInstance().debugPrintln("Uploading sensor data to Firebase...");

    // Create a JSON document to store both the battery life and distance data.
    JsonDocument doc;

    // Add the battery life percentage and distance measurement to the JSON document.
    doc["device_id"] = DEVICE_ID;
    doc["battery_level"] = batteryLife;
    doc["salt_distance"] = distance;

    // Serialize the JSON document to a string.
    String payload;
    serializeJson(doc, payload);

    DebugService::getInstance().debugPrintln("Payload: " + payload);

    // Define the Firebase endpoint URL for uploading sensor data.
    const char *firebaseCombinedEndpoint = getEndpoint();

    DebugService::getInstance().debugPrintln(String("Using updateDeviceLevels endpoint, ") + firebaseCombinedEndpoint);

    // Send a POST request to the Firebase endpoint with the combined JSON payload.
    bool success = sendPostRequest(firebaseCombinedEndpoint, payload);

    return success;
  }

private:
  static const char *firebaseBatteryEndpoint;  ///< Firebase endpoint URL for battery life data.
  static const char *firebaseDistanceEndpoint; ///< Firebase endpoint URL for distance measurement data.

  /**
   * @brief Retrieves the appropriate Firebase Functions endpoint based on the build configuration.
   *
   * This function uses the preprocessor flag `FLAVOR` to determine whether the firmware is built
   * for a development (`dev`) or production (`prod`) environment. Depending on the value of the
   * `FLAVOR` flag, the function returns the corresponding Firebase Functions endpoint URL:
   *
   * - `FLAVOR == 1`: The endpoint for the development environment (e.g., using the Firebase Emulator Suite).
   * - `FLAVOR == 2`: The endpoint for the production environment (e.g., the live Firebase Functions URL).
   *
   * The `FLAVOR` flag is defined in the `platformio.ini` file under `build_flags`:
   *
   * ```ini
   * build_flags = -D FLAVOR=1  # Development environment
   * # or
   * build_flags = -D FLAVOR=2  # Production environment
   * ```
   *
   * If the `FLAVOR` flag is not defined or has an invalid value, the preprocessor will trigger a
   * compilation error, prompting the user to correctly set the `FLAVOR` flag.
   *
   * @return The Firebase Functions endpoint URL as a `const char*`.
   *
   * @note This function ensures that the correct endpoint is used at compile-time, reducing
   * runtime logic and improving efficiency. The use of preprocessor directives makes it easy to
   * switch between environments without modifying the source code.
   *
   * @throws Compilation error if `FLAVOR` is undefined or invalid.
   */
  const char *getEndpoint() {
// Return the appropriate endpoint based on the FLAVOR flag
#if defined(FLAVOR) && (FLAVOR == 1)
    return "http://192.168.86.39:5001/brine-3b212/us-central1/updateDeviceLevels";
#elif defined(FLAVOR) && (FLAVOR == 2)
    return "https://updatedevicelevels-7wo3szegoq-uc.a.run.app";
#else
#error "FLAVOR not defined or invalid. Please set FLAVOR to 1 (dev) or 2 (prod) in platformio.ini."
#endif
  }

  /**
   * @brief Sends a POST request to a specified Firebase endpoint with a signed JSON payload.
   *
   * @details This method signs the JSON payload using the cryptographic coprocessor's private key and includes
   * the signature in the `X-Signature` header. The Firebase backend verifies the signature using the device's
   * public key, ensuring authenticity and data integrity.
   *
   * @param endpoint The Firebase endpoint URL.
   * @param jsonPayload The JSON string payload to be sent.
   * @return true if the request was successful, false otherwise.
   */
  bool sendPostRequest(const char *endpoint, const String &jsonPayload) {
    // Create an HTTP client object and send a POST request to the specified Firebase endpoint with the JSON payload.
    HTTPClient http;

    // Create a CryptoService instance to sign the request.
    CryptoService cryptoService;

    // Begin the HTTP connection
    http.begin(endpoint);

    // Add the necessary HTTP headers
    http.addHeader("Content-Type", "application/json");

    // Sign the JSON payload
    String signature;
    try {
      DebugService::getInstance().debugPrintln("Signing the request payload...");
      if (!cryptoService.signRequest(jsonPayload, signature)) {
        DebugService::getInstance().debugPrintln("Failed to sign the request.");
        http.end(); // Close the connection
        return false;
      }
      // Add the signature to the HTTP headers
      http.addHeader("X-Signature", signature);
    } catch (const std::exception &e) {
      DebugService::getInstance().debugPrint("Exception occurred during signing: ");
      DebugService::getInstance().debugPrintln(e.what());
      http.end(); // Close the connection
      return false;
    }

    // Send the POST request and store the HTTP response code
    int httpResponseCode;
    try {
      DebugService::getInstance().debugPrintln("Sending POST request...");
      httpResponseCode = http.POST(jsonPayload);
    } catch (const std::exception &e) {
      DebugService::getInstance().debugPrint("Failed to send POST request with exception: ");
      DebugService::getInstance().debugPrintln(e.what());
      http.end(); // Close the connection
      return false;
    }

    // Print the response payload for debugging
    if (httpResponseCode > 0) {
      String response = http.getString();
      DebugService::getInstance().debugPrintln("Response: " + response);
    } else {
      DebugService::getInstance().debugPrintln("Error on sending POST: " + String(httpResponseCode));
    }

    // End the HTTP session
    http.end();

    // Return true if the HTTP response code is 200 (OK) or 201 (Created)
    return (httpResponseCode == 200 || httpResponseCode == 201);
  }
};

#endif // FIREBASESERVICE_H