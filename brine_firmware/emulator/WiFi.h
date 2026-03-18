/**
 * @file WiFi.h
 * @brief WiFi API stub for the native emulator.
 *
 * Provides a minimal WiFi class that reports as always-connected. The emulator
 * runs on the host machine's network stack, so WiFi management is not needed.
 * The macAddress() method returns a fixed value for consistent DeviceName generation.
 */
#ifndef WIFI_H_EMULATOR
#define WIFI_H_EMULATOR

#include "Arduino.h"

#define WL_CONNECTED 3
#define WL_NO_SSID_AVAIL 1
#define WL_CONNECT_FAILED 4

/// Stub IP address class for WiFi.localIP().
class IPAddress {
public:
  String toString() const { return "127.0.0.1"; }
};

/// Stub WiFi class that always reports as connected.
class WiFiClass {
public:
  void begin(const char *, const char * = nullptr) {}
  void disconnect() {}
  void setHostname(const char *) {}
  int status() const { return WL_CONNECTED; }
  String macAddress() const { return "EM:UL:AT:OR:00:01"; }
  IPAddress localIP() const { return IPAddress(); }
  int scanNetworks() { return 0; }
  String SSID(int) { return ""; }
  int RSSI(int) { return 0; }
};

static WiFiClass WiFi;

/// Stub WiFiClient for HTTP operations. Not used directly by the emulator
/// since EmulatorHTTPClient uses libcurl, but needed to satisfy includes.
class WiFiClient {};
class WiFiClientSecure : public WiFiClient {
public:
  void setInsecure() {}
};

#endif // WIFI_H_EMULATOR
