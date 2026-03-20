#ifndef TEST_BLEMODULE_H
#define TEST_BLEMODULE_H

#include <unity.h>
#include <Wire.h>
#include "BLEModule.h"

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
    BLEModule bleModule;

    bool beginResult = bleModule.begin();

    TEST_ASSERT_TRUE_MESSAGE(beginResult, "BLE module failed to start");
}

/**
 * @brief Test for starting BLE advertising.
 *
 * This function tests the `advertise` function of the BLEModule class.
 */
void test_ble_module_advertise(void) {
    BLEModule bleModule;

    bool advertiseResult = bleModule.advertise();

    TEST_ASSERT_TRUE_MESSAGE(advertiseResult, "BLE module failed to advertise");
}

#endif