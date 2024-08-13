// Filename: FirebaseService.h
#ifndef FIREBASESERVICE_H
#define FIREBASESERVICE_H

#include <ArduinoJson.h>
#include <HTTPClient.h>
#include "DeviceConfig.h"

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
    // Create a JSON document to store both the battery life and distance data.
    JsonDocument doc;

    // Add the battery life percentage and distance measurement to the JSON document.
    doc["device_id"] = DEVICE_ID;
    doc["battery_level"] = batteryLife;
    doc["salt_level"] = distance;

    // Serialize the JSON document to a string.
    String payload;
    serializeJson(doc, payload);

    // Define the Firebase endpoint URL for uploading sensor data.
    // TODO update endpoint for production.
    const char *firebaseCombinedEndpoint = "http://192.168.86.28:5001/brine-3b212/us-central1/updateDeviceLevels";

    // Send a POST request to the Firebase endpoint with the combined JSON payload.
    bool success = sendPostRequest(firebaseCombinedEndpoint, payload);

    return success;
  }

private:
  static const char *firebaseBatteryEndpoint;  ///< Firebase endpoint URL for battery life data.
  static const char *firebaseDistanceEndpoint; ///< Firebase endpoint URL for distance measurement data.

  /**
   * @brief Sends a POST request to a specified Firebase endpoint with JSON payload.
   *
   * @param endpoint The Firebase endpoint URL.
   * @param jsonPayload The JSON string payload to be sent.
   * @return true if the request was successful, false otherwise.
   */
  bool sendPostRequest(const char *endpoint, const String &jsonPayload) {
    // Create an HTTP client object and send a POST request to the specified Firebase endpoint with the JSON payload.
    HTTPClient http;
    http.begin(endpoint);
    http.addHeader("Content-Type", "application/json");

    // TODO: Add authentication header
    // This could involve generating a token using the cryptographic coprocessor and adding it as a header.
    // Example: http.addHeader("Authorization", "Bearer <token>");

    // Send the POST request and store the HTTP response code.
    int httpResponseCode = http.POST(jsonPayload);

    // End the HTTP session.
    http.end();

    // Return true if the HTTP response code is 200 (OK).
    return httpResponseCode == 200;
  }
};

#endif // FIREBASESERVICE_H