/*
 *  Test file for the NVSService class. This test file verifies the functionality of
 *  saving and retrieving JSON documents to and from the Non-Volatile Storage (NVS).
 *
 *  Run this test with the command `pio test --filter test_NVSService`.
 */

#include <Arduino.h>
#include <ArduinoJson.h>
#include "NVSService.h"
#include <unity.h>
#include <Wire.h>
#include "test_NVSService.h"

/**
 * @brief Initializes the test suite and runs the test cases.
 *
 * This function is called once at the beginning of the test suite. It
 * initializes the Unity test framework and runs the test cases defined in the
 * suite.
 */
void setup() {
    UNITY_BEGIN();
    
    RUN_TEST(test_nvs_initialization);
    RUN_TEST(test_save_json);
    RUN_TEST(test_retrieve_json);
    // An attempt to re-initialize NVS should still succeed
    RUN_TEST(test_nvs_initialization);
    RUN_TEST(test_erase_key);
    RUN_TEST(test_erase_all);
    
    // Clear NVS after tests to ensure a clean state
    bool cleanupResult = nvsService.eraseAll();
    if (cleanupResult) {
        DebugService::getInstance().debugPrintln("NVS cleared after tests.");
    } else {
        DebugService::getInstance().debugPrintln("Failed to clear NVS after tests.");
    }
    
    UNITY_END();
}

void loop() {
    // No operation needed in loop
}