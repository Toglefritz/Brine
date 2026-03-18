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
 * This emulator is a development tool for testing the mobile app and backend
 * without requiring physical ESP32 hardware.
 *
 * Usage:
 *   pio run -e emulator && .pio/build/emulator/program
 *
 * Commands (entered at the prompt):
 *   upload              - Upload current sensor values to Firebase
 *   set battery <value> - Set battery level (0-100)
 *   set distance <value> - Set salt distance in mm
 *   status              - Show current sensor values
 *   psk <key>           - Store a pre-shared key in NVS
 *   quit                - Exit the emulator
 */

#include "Arduino.h"
#include "DeviceConfig.h"
#include "FirebaseService.h"

#include <cstdio>
#include <cstring>
#include <string>

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
      printf("  upload               Upload sensor data to Firebase\n");
      printf("  set battery <value>  Set battery level (0-100)\n");
      printf("  set distance <value> Set salt distance in mm\n");
      printf("  status               Show current sensor values\n");
      printf("  psk <key>            Store a pre-shared key\n");
      printf("  quit                 Exit the emulator\n");
    } else if (strcmp(line, "upload") == 0) {
      uploadSensorData();
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
