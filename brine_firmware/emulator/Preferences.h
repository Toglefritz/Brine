/**
 * @file Preferences.h
 * @brief File-backed key-value store replacing ESP32 NVS Preferences.
 *
 * Stores data as JSON files in a local `.emulator_nvs/` directory, one file
 * per namespace. This allows the emulator to persist WiFi credentials, PSK,
 * and other NVS data across runs, matching the firmware's NVS behavior.
 */
#ifndef PREFERENCES_H_EMULATOR
#define PREFERENCES_H_EMULATOR

#include "Arduino.h"
#include <fstream>
#include <map>
#include <string>
#include <sys/stat.h>

/// File-backed Preferences class matching the ESP32 Preferences API.
class Preferences {
public:
  Preferences() : _open(false) {}

  /// Open a namespace for reading and writing.
  bool begin(const char *name, bool readOnly = false) {
    _namespace = name;
    _open = true;
    _load();
    return true;
  }

  /// Close the namespace.
  void end() {
    if (_open) {
      _save();
      _open = false;
    }
  }

  /// Store a string value.
  bool putString(const char *key, const String &value) {
    if (!_open) return false;
    _data[key] = std::string(value.c_str());
    _save();
    return true;
  }

  /// Retrieve a string value, returning defaultValue if not found.
  String getString(const char *key, const String &defaultValue = String("")) {
    if (!_open) return defaultValue;
    auto it = _data.find(key);
    if (it != _data.end()) {
      return String(it->second.c_str());
    }
    return defaultValue;
  }

  /// Remove a single key.
  bool remove(const char *key) {
    if (!_open) return false;
    _data.erase(key);
    _save();
    return true;
  }

  /// Clear all keys in the current namespace.
  bool clear() {
    if (!_open) return false;
    _data.clear();
    _save();
    return true;
  }

private:
  std::string _namespace;
  std::map<std::string, std::string> _data;
  bool _open;

  /// Returns the file path for the current namespace.
  std::string _filePath() const {
    return ".emulator_nvs/" + _namespace + ".txt";
  }

  /// Load key-value pairs from disk. Format: one "key=value" per line.
  void _load() {
    _data.clear();
    std::ifstream file(_filePath());
    if (!file.is_open()) return;

    std::string line;
    while (std::getline(file, line)) {
      size_t eq = line.find('=');
      if (eq != std::string::npos) {
        std::string key = line.substr(0, eq);
        std::string val = line.substr(eq + 1);
        _data[key] = val;
      }
    }
  }

  /// Save key-value pairs to disk.
  void _save() const {
    mkdir(".emulator_nvs", 0755);
    std::ofstream file(_filePath());
    if (!file.is_open()) return;

    for (const auto &kv : _data) {
      file << kv.first << "=" << kv.second << "\n";
    }
  }
};

#endif // PREFERENCES_H_EMULATOR
