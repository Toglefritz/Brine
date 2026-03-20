// Filename: OTAService.cpp
//
// OTA (Over-The-Air) Service Implementation
// Handles firmware updates via cloud (HTTP) and Bluetooth (BLE)
// Supports both development and production environments with different
// endpoints

#include "OTAService.h"

/**
 * Check for available firmware updates from the cloud endpoint
 *
 * Sends device ID and current firmware version to the server and checks
 * if a newer version is available for download.
 *
 * @param latestVersion Output parameter - populated with the latest version
 * string if update available
 * @param downloadUrl Output parameter - populated with the firmware download
 * URL if update available
 * @return true if an update is available, false otherwise
 */
bool OTAService::checkForUpdate(String &latestVersion, String &downloadUrl) {
  DebugService::getInstance().debugPrintln("Checking for firmware updates...");

  HTTPClient http;
  const char *endpoint = getOTAEndpoint();

  // Prepare request payload with device identification and current version
  JsonDocument doc;
  doc["device_id"] = DEVICE_ID;
  doc["current_version"] = FIRMWARE_VERSION;

  String payload;
  serializeJson(doc, payload);

  // Begin HTTP connection (SSL in production, plain HTTP in development)
  if (isDevelopment()) {
    http.begin(endpoint);
  } else {
    // In production, use SSL with insecure mode (no certificate validation)
    // Use static to keep the client alive for the duration of the request
    static WiFiClientSecure secureClient;
    secureClient.setInsecure(); // Skip certificate validation
    
    if (!http.begin(secureClient, endpoint)) {
      DebugService::getInstance().debugPrintln("Failed to begin HTTPS connection");
      return false;
    }
  }

  http.addHeader("Content-Type", "application/json");

  // Send POST request to check for updates
  int httpResponseCode = http.POST(payload);

  if (httpResponseCode == 200) {
    String response = http.getString();
    DebugService::getInstance().debugPrintln("Update check response: " +
                                             response);

    // Parse JSON response
    JsonDocument responseDoc;
    DeserializationError error = deserializeJson(responseDoc, response);

    if (error) {
      DebugService::getInstance().debugPrintln(
          "Failed to parse update response");
      http.end();
      return false;
    }

    bool updateAvailable = responseDoc["update_available"] | false;

    if (updateAvailable) {
      // Extract update information from response
      latestVersion = responseDoc["latest_version"].as<String>();
      downloadUrl = responseDoc["download_url"].as<String>();

      DebugService::getInstance().debugPrintln("Update available: " +
                                               latestVersion);
      http.end();
      return true;
    } else {
      DebugService::getInstance().debugPrintln(
          "No update available. Current version is up to date.");
    }
  } else {
    DebugService::getInstance().debugPrintln(
        "Failed to check for updates. HTTP code: " + String(httpResponseCode));
  }

  http.end();
  return false;
}

/**
 * Download and install firmware update from cloud URL
 *
 * Downloads the firmware binary from the provided URL, writes it to flash
 * memory in chunks, and reboots the device upon successful installation.
 *
 * @param downloadUrl The URL to download the firmware binary from
 * @return true if update was successful (device will reboot), false on failure
 */
bool OTAService::performCloudUpdate(const String &downloadUrl) {
  DebugService::getInstance().debugPrintln("Starting cloud OTA update from: " +
                                           downloadUrl);

  HTTPClient http;

  // Connect to download URL (SSL in production, plain HTTP in development)
  if (isDevelopment()) {
    http.begin(downloadUrl);
  } else {
    // In production, use SSL with insecure mode (no certificate validation)
    // Use static to keep the client alive for the duration of the request
    static WiFiClientSecure secureClient;
    secureClient.setInsecure(); // Skip certificate validation
    
    if (!http.begin(secureClient, downloadUrl)) {
      DebugService::getInstance().debugPrintln("Failed to begin HTTPS connection");
      return false;
    }
  }

  int httpCode = http.GET();

  if (httpCode != 200) {
    DebugService::getInstance().debugPrintln(
        "Failed to download firmware. HTTP code: " + String(httpCode));
    http.end();
    return false;
  }

  // Validate firmware size
  int contentLength = http.getSize();
  if (contentLength <= 0) {
    DebugService::getInstance().debugPrintln("Invalid content length");
    http.end();
    return false;
  }

  DebugService::getInstance().debugPrintln(
      "Firmware size: " + String(contentLength) + " bytes");

  // Initialize ESP32 Update library with firmware size
  bool canBegin = Update.begin(contentLength);
  if (!canBegin) {
    DebugService::getInstance().debugPrintln("Not enough space for OTA update");
    http.end();
    return false;
  }

  // Track update progress
  updateInProgress = true;
  totalSize = contentLength;
  bytesWritten = 0;

  // Stream firmware data in chunks
  WiFiClient *stream = http.getStreamPtr();
  uint8_t buffer[128];

  while (http.connected() && (bytesWritten < totalSize)) {
    size_t available = stream->available();

    if (available) {
      // Read chunk from stream
      int bytesToRead =
          ((available > sizeof(buffer)) ? sizeof(buffer) : available);
      int bytesRead = stream->readBytes(buffer, bytesToRead);

      // Write chunk to flash memory
      size_t written = Update.write(buffer, bytesRead);
      if (written != bytesRead) {
        DebugService::getInstance().debugPrintln("Error writing update data");
        Update.abort();
        updateInProgress = false;
        http.end();
        return false;
      }

      bytesWritten += written;

      // Report progress every 10%
      int progress = (bytesWritten * 100) / totalSize;
      static int lastProgress = 0;
      if (progress >= lastProgress + 10) {
        DebugService::getInstance().debugPrintln(
            "Update progress: " + String(progress) + "%");
        lastProgress = progress;
      }
    }
    delay(1);
  }

  http.end();

  // Finalize update and reboot if successful
  if (bytesWritten == totalSize) {
    DebugService::getInstance().debugPrintln("Firmware download complete");

    if (Update.end(true)) {
      DebugService::getInstance().debugPrintln(
          "OTA update successful! Rebooting...");
      updateInProgress = false;
      delay(1000);
      ESP.restart();
      return true;
    } else {
      DebugService::getInstance().debugPrintln("Error finalizing update: " +
                                               String(Update.getError()));
    }
  } else {
    DebugService::getInstance().debugPrintln("Download incomplete");
  }

  updateInProgress = false;
  return false;
}

/**
 * Initialize a Bluetooth OTA update session
 *
 * Prepares the device to receive firmware data over Bluetooth by allocating
 * flash memory space and initializing the update process.
 *
 * @param firmwareSize Total size of the firmware binary to be received
 * @return true if initialization successful, false if already updating or
 * insufficient space
 */
bool OTAService::beginBluetoothUpdate(size_t firmwareSize) {
  DebugService::getInstance().debugPrintln(
      "Beginning Bluetooth OTA update. Size: " + String(firmwareSize));

  if (updateInProgress) {
    DebugService::getInstance().debugPrintln("Update already in progress");
    return false;
  }

  // Allocate flash memory for the incoming firmware
  if (!Update.begin(firmwareSize)) {
    DebugService::getInstance().debugPrintln("Not enough space for OTA update");
    return false;
  }

  updateInProgress = true;
  totalSize = firmwareSize;
  bytesWritten = 0;

  DebugService::getInstance().debugPrintln("Ready to receive firmware data");
  return true;
}

/**
 * Write a chunk of firmware data received over Bluetooth
 *
 * Called repeatedly to write firmware data chunks to flash memory during
 * a Bluetooth OTA update session. Tracks progress and reports every 10%.
 *
 * @param data Pointer to the firmware data chunk
 * @param len Length of the data chunk in bytes
 * @return true if chunk written successfully, false on error
 */
bool OTAService::writeBluetoothChunk(const uint8_t *data, size_t len) {
  if (!updateInProgress) {
    DebugService::getInstance().debugPrintln("No update in progress");
    return false;
  }

  // Write chunk to flash memory
  size_t written = Update.write(const_cast<uint8_t *>(data), len);
  if (written != len) {
    DebugService::getInstance().debugPrintln("Error writing chunk");
    return false;
  }

  bytesWritten += written;

  // Report progress every 10%
  int progress = (bytesWritten * 100) / totalSize;
  static int lastProgress = 0;
  if (progress >= lastProgress + 10) {
    DebugService::getInstance().debugPrintln(
        "BLE Update progress: " + String(progress) + "%");
    lastProgress = progress;
  }

  return true;
}

/**
 * Finalize a Bluetooth OTA update and reboot
 *
 * Validates that all firmware data was received, finalizes the update process,
 * and reboots the device if successful.
 *
 * @return true if update finalized successfully (device will reboot), false on
 * error
 */
bool OTAService::endBluetoothUpdate() {
  if (!updateInProgress) {
    DebugService::getInstance().debugPrintln("No update in progress");
    return false;
  }

  // Verify all firmware data was received
  if (bytesWritten != totalSize) {
    DebugService::getInstance().debugPrintln("Incomplete firmware received");
    Update.abort();
    updateInProgress = false;
    return false;
  }

  // Finalize the update and reboot
  if (Update.end(true)) {
    DebugService::getInstance().debugPrintln(
        "Bluetooth OTA update successful! Rebooting...");
    updateInProgress = false;
    delay(1000);
    ESP.restart();
    return true;
  } else {
    DebugService::getInstance().debugPrintln("Error finalizing update: " +
                                             String(Update.getError()));
    updateInProgress = false;
    return false;
  }
}

/**
 * Abort an in-progress OTA update
 *
 * Cancels the current update operation and cleans up resources.
 * Can be called for both cloud and Bluetooth updates.
 */
void OTAService::abortUpdate() {
  if (updateInProgress) {
    Update.abort();
    updateInProgress = false;
    bytesWritten = 0;
    totalSize = 0;
    DebugService::getInstance().debugPrintln("OTA update aborted");
  }
}

/**
 * Get the OTA endpoint URL based on build flavor
 *
 * Returns the appropriate firmware update check endpoint:
 * - FLAVOR 1 (dev): Local Firebase emulator endpoint
 * - FLAVOR 2 (prod): Production Cloud Run endpoint
 *
 * @return Pointer to the endpoint URL string
 */
const char *OTAService::getOTAEndpoint() {
#if defined(FLAVOR) && (FLAVOR == 1)
  return "http://192.168.86.39:5001/brine-3b212/us-central1/"
         "checkFirmwareUpdate";
#elif defined(FLAVOR) && (FLAVOR == 2)
  return "https://checkfirmwareupdate-7wo3szegoq-uc.a.run.app";
#else
#error                                                                         \
    "FLAVOR not defined or invalid. Please set FLAVOR to 1 (dev) or 2 (prod) in platformio.ini."
#endif
}

/**
 * Check if running in development mode
 *
 * Determines the build environment based on the FLAVOR compile-time constant.
 *
 * @return true if FLAVOR is 1 (development), false if FLAVOR is 2 (production)
 */
bool OTAService::isDevelopment() {
#if defined(FLAVOR) && (FLAVOR == 1)
  return true;
#elif defined(FLAVOR) && (FLAVOR == 2)
  return false;
#else
#error                                                                         \
    "FLAVOR not defined or invalid. Please set FLAVOR to 1 (dev) or 2 (prod) in platformio.ini."
#endif
}

/**
 * Compare semantic version strings to determine if an update is newer
 *
 * Parses version strings in the format "major.minor.patch" and compares them
 * to determine if the latest version is newer than the current version.
 *
 * @param current Current firmware version string (e.g., "1.2.3")
 * @param latest Latest available firmware version string (e.g., "1.3.0")
 * @return true if latest version is newer than current version, false otherwise
 */
bool OTAService::isNewerVersion(const String &current, const String &latest) {
  // Parse semantic version components (major.minor.patch)
  int currentMajor = 0, currentMinor = 0, currentPatch = 0;
  int latestMajor = 0, latestMinor = 0, latestPatch = 0;

  sscanf(current.c_str(), "%d.%d.%d", &currentMajor, &currentMinor,
         &currentPatch);
  sscanf(latest.c_str(), "%d.%d.%d", &latestMajor, &latestMinor, &latestPatch);

  // Compare versions hierarchically: major > minor > patch
  if (latestMajor > currentMajor)
    return true;
  if (latestMajor == currentMajor && latestMinor > currentMinor)
    return true;
  if (latestMajor == currentMajor && latestMinor == currentMinor &&
      latestPatch > currentPatch)
    return true;

  return false;
}
