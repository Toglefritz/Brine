/**
 * @file emulator_main.cpp
 * @brief Native emulator entry point for the Brine firmware.
 *
 * Simulates the firmware's core behavior on a desktop machine:
 * - Configurable sensor values (battery level, salt distance)
 * - Real HTTP uploads to the Firebase backend via FirebaseService
 * - File-backed NVS storage for WiFi credentials and PSK
 * - Interactive command loop for manipulating sensor state
 *
 * This emulator is a development tool for testing the mobile app and backend without requiring physical ESP32 hardware.
 *
 * Usage:
 *   pio run -e emulator && .pio/build/emulator/program
 *
 * Commands (entered at the prompt):
 *   provision <userId> [height] - Provision device onto a user account via Firebase emulator (calls addDeviceToUser,
 *                                 generatePSK, updateApplianceHeight)
 *   upload              - Upload current sensor values to Firebase
 *   set battery <value> - Set battery level (0-100)
 *   set distance <value> - Set salt distance in mm
 *   status              - Show current sensor values
 *   psk <key>           - Store a pre-shared key in NVS manually
 *   quit                - Exit the emulator
 */

#include "Arduino.h"
#include "DeviceConfig.h"
#include "FirebaseService.h"
#include "HTTPClient.h"
#include <ArduinoJson.h>

#include <cstdio>
#include <cstring>
#include <string>

/// Base URL for the Firebase emulator Cloud Functions.
static std::string getEmulatorBaseUrl() {
  return std::string("http://") + FIREBASE_EMULATOR_IP +
         ":5001/brine-3b212/us-central1";
}

/// Simulated sensor values that can be changed at runtime.
static float emulatedBatteryLevel = 85.0f;
static float emulatedSaltDistance = 150.0f;

/// FirebaseService instance (uses real HTTP via the emulator's HTTPClient).
static FirebaseService firebaseService;

/// Prints the current emulated sensor state.
void printStatus() {
  printf("\n[EMULATOR] Device ID:      %s\n", DEVICE_ID);
  printf("[EMULATOR] Battery level:  %.1f%%\n", emulatedBatteryLevel);
  printf("[EMULATOR] Salt distance:  %.1f mm\n", emulatedSaltDistance);
  printf("\n");
}

/// Uploads the current sensor values to Firebase.
void uploadSensorData() {
  printf("[EMULATOR] Uploading sensor data to Firebase...\n");
  bool success =
      firebaseService.uploadSensorData(emulatedBatteryLevel, emulatedSaltDistance);
  if (success) {
    printf("[EMULATOR] Upload successful.\n");
  } else {
    printf("[EMULATOR] Upload failed.\n");
  }
}

/// Stores a PSK into the emulated NVS so FirebaseService can generate HMACs.
void storePsk(const char *psk) {
  NVSService &nvsService = NVSService::getInstance();
  nvsService.begin("preSharedKey");
  bool result = nvsService.saveString("psk", String(psk));
  nvsService.end();
  if (result) {
    printf("[EMULATOR] PSK stored successfully.\n");
  } else {
    printf("[EMULATOR] Failed to store PSK.\n");
  }
}

/**
 * @brief Provisions the emulated device against the Firebase emulator backend.
 *
 * Replicates the provisioning flow that normally happens over BLE between the mobile app and the physical device. Calls 
 * the same Cloud Function endpoints the mobile app uses:
 *   1. addDeviceToUser — associates the device with a user account
 *   2. generatePSK — creates a pre-shared key for HMAC-signed uploads
 *   3. updateApplianceHeight — sets the water softener height for salt % calc
 *
 * The Firebase emulator auth middleware accepts an X-User-ID header in place of a real Firebase ID token, so no actual 
 * authentication is needed.
 *
 * @param userId The user ID to associate the device with.
 * @param applianceHeight The water softener height in millimeters.
 */
void provisionDevice(const char *userId, int applianceHeight) {
  printf("[PROVISION] Starting provisioning for device '%s' with user '%s'...\n",
         DEVICE_ID, userId);

  HTTPClient http;
  std::string baseUrl = getEmulatorBaseUrl();
  std::string url;

  // --- Step 1: Add device to user account ---
  printf("[PROVISION] Step 1/3: Associating device with user account...\n");

  url = baseUrl + "/addDeviceToUser";
  http.begin(url.c_str());
  http.addHeader("Content-Type", String("application/json"));
  http.addHeader("X-User-ID", String(userId));

  JsonDocument addDeviceDoc;
  addDeviceDoc["deviceId"] = DEVICE_ID;
  addDeviceDoc["deviceName"] = "emu1";
  String addDevicePayload;
  serializeJson(addDeviceDoc, addDevicePayload);

  int code = http.POST(addDevicePayload);
  printf("[PROVISION]   Response: %d - %s\n", code, http.getString().c_str());
  http.end();

  if (code != 200) {
    printf("[PROVISION] Failed at step 1. Aborting.\n");
    return;
  }

  // --- Step 2: Generate PSK ---
  printf("[PROVISION] Step 2/3: Generating pre-shared key...\n");

  url = baseUrl + "/generatePSK";
  http.begin(url.c_str());
  http.addHeader("Content-Type", String("application/json"));
  http.addHeader("X-User-ID", String(userId));

  JsonDocument pskRequestDoc;
  pskRequestDoc["deviceId"] = DEVICE_ID;
  String pskPayload;
  serializeJson(pskRequestDoc, pskPayload);

  code = http.POST(pskPayload);
  String pskResponse = http.getString();
  printf("[PROVISION]   Response: %d - %s\n", code, pskResponse.c_str());
  http.end();

  if (code != 200) {
    printf("[PROVISION] Failed at step 2. Aborting.\n");
    return;
  }

  // Parse the PSK from the response and store it in NVS
  JsonDocument pskResponseDoc;
  DeserializationError err = deserializeJson(pskResponseDoc, pskResponse);
  if (err) {
    printf("[PROVISION] Failed to parse PSK response. Aborting.\n");
    return;
  }

  const char *psk = pskResponseDoc["psk"];
  if (!psk) {
    printf("[PROVISION] No 'psk' field in response. Aborting.\n");
    return;
  }

  storePsk(psk);

  // --- Step 3: Set appliance height ---
  printf("[PROVISION] Step 3/3: Setting appliance height to %d mm...\n",
         applianceHeight);

  url = baseUrl + "/updateApplianceHeight";
  http.begin(url.c_str());
  http.addHeader("Content-Type", String("application/json"));
  http.addHeader("X-User-ID", String(userId));

  JsonDocument heightDoc;
  heightDoc["deviceId"] = DEVICE_ID;
  heightDoc["applianceHeight"] = applianceHeight;
  String heightPayload;
  serializeJson(heightDoc, heightPayload);

  code = http.POST(heightPayload);
  printf("[PROVISION]   Response: %d - %s\n", code, http.getString().c_str());
  http.end();

  if (code != 200) {
    printf("[PROVISION] Failed at step 3. Aborting.\n");
    return;
  }

  printf("[PROVISION] Provisioning complete. Device is ready to upload sensor "
         "data.\n");
}

/// Main entry point for the native emulator.
int main() {
  printf("===========================================\n");
  printf("  Brine Firmware Emulator\n");
  printf("===========================================\n");
  printf("Type 'help' for available commands.\n");

  printStatus();

  char line[256];
  while (true) {
    printf("emulator> ");
    fflush(stdout);

    if (!fgets(line, sizeof(line), stdin)) {
      break;
    }

    // Strip trailing newline
    size_t len = strlen(line);
    if (len > 0 && line[len - 1] == '\n') {
      line[len - 1] = '\0';
    }

    if (strcmp(line, "quit") == 0 || strcmp(line, "exit") == 0) {
      printf("[EMULATOR] Exiting.\n");
      break;
    } else if (strcmp(line, "help") == 0) {
      printf("Commands:\n");
      printf("  provision <userId> [height]  Provision device onto a user account\n");
      printf("                               height: appliance height in mm (default: 1000)\n");
      printf("  upload               Upload sensor data to Firebase\n");
      printf("  set battery <value>  Set battery level (0-100)\n");
      printf("  set distance <value> Set salt distance in mm\n");
      printf("  status               Show current sensor values\n");
      printf("  psk <key>            Store a pre-shared key manually\n");
      printf("  quit                 Exit the emulator\n");
    } else if (strcmp(line, "upload") == 0) {
      uploadSensorData();
    } else if (strncmp(line, "provision ", 10) == 0) {
      // Parse: provision <userId> [height]
      char userId[128] = {0};
      int height = 1000;
      int parsed = sscanf(line + 10, "%127s %d", userId, &height);
      if (parsed >= 1) {
        provisionDevice(userId, height);
      } else {
        printf("[EMULATOR] Usage: provision <userId> [height_mm]\n");
      }
    } else if (strcmp(line, "provision") == 0) {
      printf("[EMULATOR] Usage: provision <userId> [height_mm]\n");
    } else if (strcmp(line, "status") == 0) {
      printStatus();
    } else if (strncmp(line, "set battery ", 12) == 0) {
      float val = atof(line + 12);
      if (val < 0.0f) val = 0.0f;
      if (val > 100.0f) val = 100.0f;
      emulatedBatteryLevel = val;
      printf("[EMULATOR] Battery level set to %.1f%%\n", emulatedBatteryLevel);
    } else if (strncmp(line, "set distance ", 13) == 0) {
      float val = atof(line + 13);
      if (val < 0.0f) val = 0.0f;
      emulatedSaltDistance = val;
      printf("[EMULATOR] Salt distance set to %.1f mm\n", emulatedSaltDistance);
    } else if (strncmp(line, "psk ", 4) == 0) {
      storePsk(line + 4);
    } else if (strlen(line) > 0) {
      printf("[EMULATOR] Unknown command: '%s'. Type 'help' for options.\n",
             line);
    }
  }

  return 0;
}
