#ifndef DebugService_h
#define DebugService_h

#include "Arduino.h"

/**
 * @file DebugService.h
 * @brief Service class for managing debug output in the Brine monitor IoT device firmware.
 *
 * Debugging is a critical part of developing reliable and maintainable firmware for IoT devices. The DebugService
 * class provides a centralized and standardized way to manage debug output across the Brine monitor project. It
 * allows for the conditional compilation of debug messages, making it easy to enable or disable debug output globally
 * without modifying individual print statements throughout the codebase.
 *
 * The service defines a static DEBUG flag that controls whether messages are actually sent to the Serial port. This
 * approach ensures that debug output can be easily enabled for development and testing phases but can be disabled for
 * production releases to conserve memory and processing resources, and to avoid exposing potentially sensitive
 * information.
 *
 * Key Features:
 * - **Conditional Debug Output:** The service uses the DEBUG flag to determine whether to print debug messages,
 *   allowing for easy toggling of debug output.
 * - **Centralized Debug Management:** All debug output is managed through this service, providing a single point of
 *   modification for debug settings and behaviors.
 * - **Simplified Interface:** Offers simple static methods for printing debug messages, reducing boilerplate code for
 *   debug output and ensuring consistency in how debug information is logged.
 *
 * Usage:
 *
 * 1. **Enable/Disable Debug Output:**
 *    By setting the `DEBUG` flag in the DebugService class, users can globally enable or disable debug output. This
 *    is particularly useful for transitioning between development and production builds.
 *
 * 2. **Printing Debug Messages:**
 *    DebugService::debugPrint("Message"); // Prints a single line without a newline character.
 *    DebugService::debugPrintln("Message with newline"); // Prints a message followed by a newline character.
 *
 * By centralizing debug output management, the DebugService class significantly enhances the maintainability and
 * readability of the firmware codebase. It provides a flexible and efficient mechanism for developers to include
 * diagnostic logging that can be easily enabled or disabled according to the build configuration, thereby facilitating
 * smoother development, testing, and deployment processes.
 */

/**
 * @class DebugService
 * @brief Class for handling debug messages.
 */
class DebugService
{
public:
  /**
   * @brief The DEBUG flag controls whether debug messages are printed to Serial.
   */
  static const bool DEBUG;

  /**
   * @brief Prints a debug message to the Serial port if DEBUG is true.
   * @param message The message to print.
   */
  static void debugPrint(const String &message);

  /**
   * @brief Prints a debug message with a newline to the Serial port if DEBUG is true.
   * @param message The message to print.
   */
  static void debugPrintln(const String &message);

private:
  /**
   * @brief Constructor is private to prevent instantiation.
   */
  DebugService();
};

#endif
