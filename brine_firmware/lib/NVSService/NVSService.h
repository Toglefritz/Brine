// NVSService.h
#ifndef NVSSERVICE_H
#define NVSSERVICE_H

#include "DebugService.h" // Assuming you have a DebugService for logging
#include <ArduinoJson.h>
#include <Preferences.h>

class NVSService {
public:
  // Singleton pattern to ensure only one instance exists
  static NVSService &getInstance();

  /**
   * @brief Initialize the NVS service.
   *
   * Opens the NVS namespace. Must be called before any other operations.
   *
   * @param namespaceName The namespace to use for storing data.
   * @return true if initialization is successful, false otherwise.
   */
  bool begin(const char *namespaceName);

  /**
   * @brief Save a JSON document to NVS under the specified key.
   *
   * @param key The key under which the JSON document will be stored.
   * @param doc The JSON document to store.
   * @return true if the operation is successful, false otherwise.
   */
  bool saveJSON(const char *key, const JsonDocument &doc);

  /**
   * @brief Retrieve a JSON document from NVS using the specified key.
   *
   * @param key The key associated with the JSON document.
   * @param doc The JSON document to populate with retrieved data.
   * @return true if retrieval and parsing are successful, false otherwise.
   */
  bool retrieveJSON(const char *key, JsonDocument &doc);

  /**
   * @brief Erase a specific key from NVS.
   *
   * @param key The key to erase.
   * @return true if the operation is successful, false otherwise.
   */
  bool eraseKey(const char *key);

  /**
   * @brief Erase all keys within the namespace.
   *
   * @return true if the operation is successful, false otherwise.
   */
  bool eraseAll();

private:
  Preferences preferences; // Preferences instance for NVS operations

  // Private constructor to enforce singleton pattern
  NVSService();

  // Delete copy constructor and assignment operator to prevent copies
  NVSService(const NVSService &) = delete;
  NVSService &operator=(const NVSService &) = delete;
};

#endif // NVSSERVICE_H