// Filename: FirebaseService.h
#ifndef FIREBASESERVICE_H
#define FIREBASESERVICE_H

#include "DeviceConfig.h"
#include "mbedtls/md.h"
#include <ArduinoJson.h>
#include <HTTPClient.h>
#include <NVSService.h>
#include <WiFiClientSecure.h>

/**
 * @class FirebaseService
 * @brief Provides static methods to send data to Firebase backend.
 *
 * This service class contains static methods for uploading sensor data to a Firebase backend.
 * It supports uploading battery life percentage and distance sensor measurements. The class
 * uses HTTP POST requests to send data to predefined Firebase endpoints.
 *
 * @note This class assumes the presence of an active internet connection.
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
   * @brief Retrieves the PSK from NVS for use in generating an HMAC.
   *
   * This function initializes the NVSService with the "preSharedKey" namespace and attempts
   * to retrieve the stored pre-shared key (PSK) as a simple string. If initialization fails
   * or the PSK is not found, an error is logged and an empty string is returned.
   *
   * @return A string containing the PSK if retrieval is successful, or an empty string if an error occurs.
   */
  String loadPsk() {
    // Get an instance of the NVSService singleton
    NVSService &nvsService = NVSService::getInstance();

    // Initialize NVSService with the "preSharedKey" namespace
    bool initResult = nvsService.begin("preSharedKey");

    // Check that initialization was successful
    if (!initResult) {
      DebugService::getInstance().debugPrintln("Error: Failed to initialize NVSService for 'preSharedKey'.");
      return ""; // Return an empty string to indicate failure
    }

    // Retrieve the PSK as a string from NVS
    String psk = nvsService.getString("psk");
    if (psk.isEmpty()) {
      DebugService::getInstance().debugPrintln("Error: PSK not found in NVS.");
      nvsService.end(); // End the NVS session before returning
      return "";        // Explicitly return an empty string on failure
    }

    DebugService::getInstance().debugPrintln("PSK successfully loaded from NVS.");

    // End NVS session
    nvsService.end();

    // Return the PSK
    return psk;
  }

  /**
   * @brief Generates an HMAC (Hash-based Message Authentication Code) using SHA-256 with the mbedTLS library.
   *
   * This function takes a payload and a pre-shared key (PSK) as input, and produces an HMAC using the SHA-256
   * hashing algorithm provided by the mbedTLS library. The resulting HMAC is returned as a hexadecimal string.
   * If the PSK cannot be retrieved or an error occurs during HMAC computation, an empty string is returned.
   *
   * @param payload The input string to be hashed.
   * @return A hexadecimal string representing the HMAC of the input payload, or an empty string if an error occurs.
   */
  String generateHMAC(String payload) {
    // Get the PSK
    String psk = loadPsk();
    if (psk.isEmpty()) {
      DebugService::getInstance().debugPrintln("Error: Cannot generate HMAC without a valid PSK.");
      return ""; // Return an empty string to indicate failure
    }

    // Initialize the mbedTLS context and set up the HMAC operation
    mbedtls_md_context_t ctx;
    mbedtls_md_init(&ctx);

    const mbedtls_md_info_t *md_info = mbedtls_md_info_from_type(MBEDTLS_MD_SHA256);
    if (md_info == nullptr) {
      DebugService::getInstance().debugPrintln("Error: Failed to get SHA-256 info for HMAC.");
      mbedtls_md_free(&ctx);
      return "";
    }

    if (mbedtls_md_setup(&ctx, md_info, 1) != 0) { // 1 indicates HMAC mode
      DebugService::getInstance().debugPrintln("Error: Failed to set up HMAC context.");
      mbedtls_md_free(&ctx);
      return "";
    }

    // Start the HMAC process with the PSK
    if (mbedtls_md_hmac_starts(&ctx, (const unsigned char *)psk.c_str(), psk.length()) != 0) {
      DebugService::getInstance().debugPrintln("Error: Failed to start HMAC computation.");
      mbedtls_md_free(&ctx);
      return "";
    }

    // Update the HMAC with the payload
    if (mbedtls_md_hmac_update(&ctx, (const unsigned char *)payload.c_str(), payload.length()) != 0) {
      DebugService::getInstance().debugPrintln("Error: Failed to update HMAC with payload.");
      mbedtls_md_free(&ctx);
      return "";
    }

    // Finalize the HMAC computation
    unsigned char hmacResult[32]; // SHA-256 produces a 32-byte hash
    if (mbedtls_md_hmac_finish(&ctx, hmacResult) != 0) {
      DebugService::getInstance().debugPrintln("Error: Failed to finish HMAC computation.");
      mbedtls_md_free(&ctx);
      return "";
    }

    // Free the mbedTLS context
    mbedtls_md_free(&ctx);

    // Convert the HMAC result to a hexadecimal string
    String hmacHex = "";
    for (int i = 0; i < 32; i++) {
      if (hmacResult[i] < 16) {
        hmacHex += "0"; // Add leading zero for single-digit bytes
      }
      hmacHex += String(hmacResult[i], HEX);
    }

    DebugService::getInstance().debugPrintln("HMAC successfully generated.");
    
    return hmacHex;
  }

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
   * @brief Returns a boolean indicating if the device is in the development environment.
   */
  const bool isDevelopment() {
#if defined(FLAVOR) && (FLAVOR == 1)
    return true;
#elif defined(FLAVOR) && (FLAVOR == 2)
    return false;
#else
#error "FLAVOR not defined or invalid. Please set FLAVOR to 1 (dev) or 2 (prod) in platformio.ini."
#endif
  }

  /**
   * @brief Sends a POST request to a specified Firebase endpoint with a signed JSON payload.
   *
   * @param endpoint The Firebase endpoint URL.
   * @param jsonPayload The JSON string payload to be sent.
   * @return true if the request was successful, false otherwise.
   */
  bool sendPostRequest(const char *endpoint, const String &jsonPayload) {
    // Generate an HMAC for the payload
    String hmac = generateHMAC(jsonPayload);
    if (hmac.isEmpty()) {
      DebugService::getInstance().debugPrintln("Error: Failed to generate HMAC. Aborting upload.");

      return false;
    }

    // Create an HTTP client object and send a POST request to the specified Firebase endpoint with the JSON payload.
    HTTPClient http;
    WiFiClient *client = nullptr;

    // Begin the HTTP connection. If the device is running in the production environment, use SSL.
    if (isDevelopment()) {
      http.begin(endpoint);
    } else {
      // In production, use SSL with insecure mode (no certificate validation)
      // Use static to keep the client alive for the duration of the request
      static WiFiClientSecure secureClient;
      secureClient.setInsecure(); // Skip certificate validation
      client = &secureClient;
      
      if (!http.begin(secureClient, endpoint)) {
        DebugService::getInstance().debugPrintln("Failed to begin HTTPS connection");
        return false;
      }
    }

    // Add the necessary HTTP headers
    http.addHeader("Content-Type", "application/json");
    http.addHeader("X-HMAC-Signature", hmac); // Include the HMAC in the request header
    http.addHeader("X-Device-ID", DEVICE_ID); // Include the device ID in the request header

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