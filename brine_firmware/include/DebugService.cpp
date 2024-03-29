#include "DebugService.h"

/// @brief Initialize the DEBUG flag. Set to false to disable debug output.
const bool DebugService::DEBUG = true;  // Set to false to disable debug output

/**
 * @brief Prints a debug message to the serial port.
 * @param message The message to print.
 */
void DebugService::debugPrint(const String &message) {
  if (DEBUG) {
    Serial.print(message);
  }
}

/**
 * @brief Prints a debug message to the serial port, followed by a newline.
 * @param message The message to print.
 */
void DebugService::debugPrintln(const String &message) {
  if (DEBUG) {
    Serial.println(message);
  }
}

/**
 * @brief Private constructor for the DebugService class.
 * @details This constructor is defined, even if it's never used.
 */
DebugService::DebugService() {}
