/**
 * @file Update.h
 * @brief Stub for ESP32 OTA Update library. OTA is not supported in the emulator.
 */
#ifndef UPDATE_H_EMULATOR
#define UPDATE_H_EMULATOR

#include <cstdint>
#include <cstddef>

/// Stub Update class. OTA updates are skipped in the emulator.
class UpdateClass {
public:
  bool begin(size_t) { return false; }
  size_t write(uint8_t *, size_t len) { return len; }
  bool end(bool = false) { return false; }
  void abort() {}
  int getError() { return 0; }
};

static UpdateClass Update;

#endif // UPDATE_H_EMULATOR
