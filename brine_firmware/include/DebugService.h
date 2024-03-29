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
 *    // Get the DebugService instance. This will initialize the Serial connection.
*     DebugService& debugService = DebugService::getInstance();

 *    debugService.debugPrint("Message"); // Prints a single line without a newline character.
 *    debugService.debugPrintln("Message with newline"); // Prints a message followed by a newline character.
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
  static const bool DEBUG = true; // Set to false to disable debug output

  /**
   * @brief Get the singleton instance of DebugService.
   * This will initialize the Serial connection if it hasn't been done yet.
   */
  static DebugService &getInstance()
  {
    static DebugService instance; // Guaranteed to be destroyed, instantiated on first use.

    return instance;
  }

  /**
   * @brief Prints a debug message to the serial port.
   * @param message The message to print.
   */
  void debugPrint(const String &message)
  {
    if (DEBUG)
    {
      Serial.print(message);
    }
  }

  /**
   * @brief Prints a debug message to the serial port, followed by a newline.
   * @param message The message to print.
   */
  void debugPrintln(const String &message)
  {
    if (DEBUG)
    {
      Serial.println(message);
    }
  }

private:
  /**
   * @brief Constructor is private to prevent instantiation.
   * Initializes the Serial connection.
   */
  DebugService()
  {
    Serial.begin(9600);
    while (!Serial)
    {
      ; // wait for serial port to connect. Needed for native USB port only
    }
  }

  // C++ 03
  // ========
  // Ensures that the following are unacceptable, otherwise it is possible
  // to accidentally get copies of this singleton appearing.
  DebugService(DebugService const &);   // Don't Implement
  void operator=(DebugService const &); // Don't implement
};

#endif
