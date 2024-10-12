// NVSService.cpp
#include "NVSService.h"

// Initialize the singleton instance
NVSService &NVSService::getInstance() {
  static NVSService instance;
  return instance;
}

/**
 * @brief Initialize the NVS service.
 *
 * Opens the NVS namespace. Must be called before any other operations.
 *
 * @param namespaceName The namespace to use for storing data.
 * @return true if initialization is successful, false otherwise.
 */
bool NVSService::begin(const char *namespaceName) {
  if (isInitialized) {
    DebugService::getInstance().debugPrintln("NVS namespace already initialized.");
    return true;
  }

  if (!preferences.begin(namespaceName, false)) { // false = Read/Write
    DebugService::getInstance().debugPrintln("Failed to open NVS namespace.");
    return false;
  }
  // Set the initialization flag
  isInitialized = true;

  DebugService::getInstance().debugPrintln("NVS namespace opened successfully.");

  return true;
}

/**
 * @brief Save a JSON document to NVS under the specified key.
 *
 * @param key The key under which the JSON document will be stored.
 * @param doc The JSON document to store.
 * @return true if the operation is successful, false otherwise.
 */
bool NVSService::saveJSON(const char *key, const JsonDocument &doc) {
  // Serialize JSON to a string
  String jsonString;
  serializeJson(doc, jsonString);

  // Store the JSON string in NVS
  bool result = preferences.putString(key, jsonString);
  if (result) {
    DebugService::getInstance().debugPrintln("JSON data saved successfully.");
  } else {
    DebugService::getInstance().debugPrintln("Failed to save JSON data.");
  }

  return result;
}

/**
 * @brief Retrieve a JSON document from NVS using the specified key.
 *
 * @param key The key associated with the JSON document.
 * @param doc The JSON document to populate with retrieved data.
 * @return true if retrieval and parsing are successful, false otherwise.
 */
bool NVSService::retrieveJSON(const char *key, JsonDocument &doc) {
  // Retrieve the JSON string from NVS
  try {
    String jsonString = preferences.getString(key, "");

    if (jsonString.isEmpty()) {
      DebugService::getInstance().debugPrintln("No data found for the given key.");

      return false;
    }

    // Deserialize JSON string into the provided JsonDocument
    DeserializationError error = deserializeJson(doc, jsonString);
    if (error) {
      DebugService::getInstance().debugPrintln("Failed to parse JSON data.");
      return false;
    }

    DebugService::getInstance().debugPrintln("JSON data retrieved and parsed successfully.");

    return true;
  } catch (...) {
    DebugService::getInstance().debugPrintln("Unable to load WiFi credentials from NVS.");

    return false;
  }
}

/**
 * @brief Erase a specific key from NVS.
 *
 * @param key The key to erase.
 * @return true if the operation is successful, false otherwise.
 */
bool NVSService::eraseKey(const char *key) {
  bool result = preferences.remove(key);
  if (result) {
    DebugService::getInstance().debugPrintln("Key erased successfully.");
  } else {
    DebugService::getInstance().debugPrintln("Failed to erase key.");
  }

  return result;
}

/**
 * @brief Erase all keys within the namespace.
 *
 * @return true if the operation is successful, false otherwise.
 */
bool NVSService::eraseAll() {
  bool result = preferences.clear();
  if (result) {
    DebugService::getInstance().debugPrintln("All keys erased successfully.");
  } else {
    DebugService::getInstance().debugPrintln("Failed to erase all keys.");
  }

  return result;
}