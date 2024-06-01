#include "BLEModule.h"
#include <Wire.h>
#include <unity.h>

/*
 *  Test file for the BLEModule class. This test file tests the functionality of
 the BLE module on the ESP32 by verifying that it initializes correctly and is
 able to begin advertising.
 *
 *  Run this test with the command `pio test --filter test_BLEModule`.
 */

/**
 * @brief Test for initializing the BLE module.
 *
 * This function tests the `begin` function of the BLEModule class.
 * It verifies if the BLE module starts successfully.
 */
void test_ble_module_begin(void) {
    BLEModule &bleModule = BLEModule::getInstance();

    bool beginResult = bleModule.begin();

    TEST_ASSERT_TRUE_MESSAGE(beginResult, "BLE module failed to start");
}

/**
 * @brief Test for starting BLE advertising.
 *
 * This function tests the `advertise` function of the BLEModule class.
 */
void test_ble_module_advertise(void) {
    BLEModule &bleModule = BLEModule::getInstance();

    bool advertiseResult = bleModule.advertise();

    TEST_ASSERT_TRUE_MESSAGE(advertiseResult, "BLE module failed to advertise");
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

    RUN_TEST(test_ble_module_begin);
    RUN_TEST(test_ble_module_advertise);

    UNITY_END();
}

void loop() {
    // Do nothing
}