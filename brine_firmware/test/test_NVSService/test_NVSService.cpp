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

// Instantiate the NVSService singleton
NVSService& nvsService = NVSService::getInstance();

/**
 * @brief Test case for NVSService initialization.
 *
 * This test verifies that the NVSService initializes correctly with the specified namespace.
 */
void test_nvs_initialization(void) {
    // Initialize NVSService with the "testNVS" namespace
    bool initResult = nvsService.begin("testNVS");
    TEST_ASSERT_TRUE_MESSAGE(initResult, "NVSService failed to initialize.");
}

/**
 * @brief Test case for saving a JSON document to NVS.
 *
 * This test verifies that a JSON document can be successfully saved to NVS under a specified key.
 */
void test_save_json(void) {
    // Create a JSON document
    JsonDocument doc;
    doc["device"] = "Brine IoT";
    doc["status"] = "active";
    
    // Save the JSON document under the key "deviceStatus"
    bool saveResult = nvsService.saveJSON("deviceStatus", doc);
    TEST_ASSERT_TRUE_MESSAGE(saveResult, "Failed to save JSON document to NVS.");
}

/**
 * @brief Test case for retrieving a JSON document from NVS.
 *
 * This test verifies that a previously saved JSON document can be retrieved and parsed correctly.
 */
void test_retrieve_json(void) {
    // Create a JSON document to hold retrieved data
    JsonDocument retrievedDoc;
    
    // Retrieve the JSON document stored under the key "deviceStatus"
    bool retrieveResult = nvsService.retrieveJSON("deviceStatus", retrievedDoc);
    TEST_ASSERT_TRUE_MESSAGE(retrieveResult, "Failed to retrieve JSON document from NVS.");
    
    // Verify the contents of the retrieved JSON
    TEST_ASSERT_EQUAL_STRING("Brine IoT", retrievedDoc["device"].as<String>().c_str());
    TEST_ASSERT_EQUAL_STRING("active", retrievedDoc["status"].as<String>().c_str());
}

/**
 * @brief Test case for erasing a specific key from NVS.
 *
 * This test verifies that a specific key-value pair can be erased from NVS and that retrieval fails afterwards.
 */
void test_erase_key(void) {
    // Erase the key "deviceStatus"
    bool eraseResult = nvsService.eraseKey("deviceStatus");
    TEST_ASSERT_TRUE_MESSAGE(eraseResult, "Failed to erase key from NVS.");
    
    // Attempt to retrieve the erased key
    JsonDocument retrievedDoc;
    bool retrieveResult = nvsService.retrieveJSON("deviceStatus", retrievedDoc);
    TEST_ASSERT_FALSE_MESSAGE(retrieveResult, "Erased key should not be retrievable.");
}

/**
 * @brief Test case for erasing all keys within the NVS namespace.
 *
 * This test verifies that all key-value pairs within the namespace can be erased successfully.
 */
void test_erase_all(void) {
    // Save multiple JSON documents
    JsonDocument doc1;
    doc1["sensor"] = "Temperature";
    doc1["value"] = 25.5;
    bool saveResult1 = nvsService.saveJSON("sensor1", doc1);
    TEST_ASSERT_TRUE_MESSAGE(saveResult1, "Failed to save JSON document sensor1 to NVS.");
    
    JsonDocument doc2;
    doc2["sensor"] = "Humidity";
    doc2["value"] = 60;
    bool saveResult2 = nvsService.saveJSON("sensor2", doc2);
    TEST_ASSERT_TRUE_MESSAGE(saveResult2, "Failed to save JSON document sensor2 to NVS.");
    
    // Erase all keys in the namespace
    bool eraseAllResult = nvsService.eraseAll();
    TEST_ASSERT_TRUE_MESSAGE(eraseAllResult, "Failed to erase all keys from NVS.");
    
    // Attempt to retrieve the erased keys
    JsonDocument retrievedDoc1;
    bool retrieveResult1 = nvsService.retrieveJSON("sensor1", retrievedDoc1);
    TEST_ASSERT_FALSE_MESSAGE(retrieveResult1, "Erased key sensor1 should not be retrievable.");
    
    JsonDocument retrievedDoc2;
    bool retrieveResult2 = nvsService.retrieveJSON("sensor2", retrievedDoc2);
    TEST_ASSERT_FALSE_MESSAGE(retrieveResult2, "Erased key sensor2 should not be retrievable.");
}

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