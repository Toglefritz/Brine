// Filename: OTAService.h
#ifndef OTASERVICE_H
#define OTASERVICE_H

#include "DebugService.h"
#include "DeviceConfig.h"
#include <ArduinoJson.h>
#include <HTTPClient.h>
#include <NVSService.h>
#include <Update.h>
#include <WiFi.h>
#include <WiFiClientSecure.h>
#include <mbedtls/md.h>

// Current firmware version - update this with each release
#define FIRMWARE_VERSION "1.0.0"

/**
 * @class OTAService
 * @brief Handles Over-The-Air (OTA) firmware updates for the Brine device.
 *
 * This service provides functionality to check for available firmware updates from the cloud,
 * download firmware binaries, and apply updates. It supports both cloud-based updates
 * (primary method) and Bluetooth-based updates (backup method).
 *
 * The service integrates with Firebase Cloud Functions to check for updates and retrieve
 * firmware binaries from Firebase Storage.
 */
class OTAService {
public:
  /**
   * @brief Checks if a firmware update is available from the cloud.
   *
   * This method sends a request to the Firebase backend to check if a newer firmware
   * version is available for the device. It compares the current firmware version with
   * the latest available version.
   *
   * @param latestVersion Output parameter that will contain the latest version string if available.
   * @param downloadUrl Output parameter that will contain the download URL if an update is available.
   * @return true if an update is available, false otherwise.
   */
  bool checkForUpdate(String &latestVersion, String &downloadUrl);

  /**
   * @brief Downloads and applies a firmware update from the specified URL.
   *
   * This method downloads the firmware binary from the provided URL and applies it
   * using the ESP32's OTA update mechanism. The device will automatically reboot
   * after a successful update.
   *
   * @param downloadUrl The URL from which to download the firmware binary.
   * @return true if the update was successfully downloaded and applied, false otherwise.
   */
  bool performCloudUpdate(const String &downloadUrl);

  /**
   * @brief Initiates a Bluetooth-based firmware update.
   *
   * This method prepares the device to receive firmware data over Bluetooth.
   * The firmware is received in chunks via BLE characteristics and written to
   * the OTA partition.
   *
   * @param firmwareSize The total size of the firmware to be received (in bytes).
   * @return true if the update preparation was successful, false otherwise.
   */
  bool beginBluetoothUpdate(size_t firmwareSize);

  /**
   * @brief Writes a chunk of firmware data during a Bluetooth update.
   *
   * This method is called repeatedly to write firmware data chunks received over
   * Bluetooth to the OTA partition.
   *
   * @param data Pointer to the firmware data chunk.
   * @param len Length of the data chunk.
   * @return true if the chunk was successfully written, false otherwise.
   */
  bool writeBluetoothChunk(const uint8_t *data, size_t len);

  /**
   * @brief Finalizes a Bluetooth-based firmware update.
   *
   * This method completes the Bluetooth update process, verifies the firmware,
   * and prepares the device to boot from the new firmware on next restart.
   *
   * @return true if the update was successfully finalized, false otherwise.
   */
  bool endBluetoothUpdate();

  /**
   * @brief Gets the current firmware version.
   *
   * @return A string containing the current firmware version.
   */
  String getCurrentVersion() const { return FIRMWARE_VERSION; }

  /**
   * @brief Aborts an ongoing OTA update.
   *
   * This method can be called to cancel an in-progress update and clean up resources.
   */
  void abortUpdate();

private:
  bool updateInProgress = false;
  size_t bytesWritten = 0;
  size_t totalSize = 0;

  /**
   * @brief Retrieves the appropriate Firebase Functions endpoint for OTA operations.
   *
   * @return The OTA endpoint URL based on the build configuration (dev/prod).
   */
  const char *getOTAEndpoint();

  /**
   * @brief Determines if the device is in development environment.
   *
   * @return true if in development mode, false if in production.
   */
  bool isDevelopment();

  /**
   * @brief Compares two semantic version strings.
   *
   * @param current The current version string (e.g., "1.0.0").
   * @param latest The latest version string (e.g., "1.1.0").
   * @return true if latest is newer than current, false otherwise.
   */
  bool isNewerVersion(const String &current, const String &latest);

  /**
   * @brief Loads the pre-shared key from NVS storage.
   *
   * Retrieves the PSK stored during device provisioning. This key is used
   * to generate HMAC signatures for authenticating requests to the cloud.
   *
   * @return The PSK string, or an empty string if retrieval fails.
   */
  String loadPsk();

  /**
   * @brief Generates an HMAC-SHA256 signature for the given payload.
   *
   * Uses the device's pre-shared key to produce a hex-encoded HMAC that
   * the cloud function can verify against its own copy of the PSK.
   *
   * @param payload The string to sign.
   * @return Hex-encoded HMAC string, or empty string on failure.
   */
  String generateHMAC(const String &payload);
};

#endif // OTASERVICE_H
