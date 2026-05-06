#include <Wire.h>
#include <unity.h>
#include "test_BLEModule.h"

/*
 *  Test file for the BLEModule class. This test file tests the functionality of
 the BLE module on the ESP32 by verifying that it initializes correctly and is
 able to begin advertising.
 *
 *  Run this test with the command `pio test -e seeed_xiao_esp32c3 --filter test_BLEModule`.
 */

/**
 * @brief Initializes the test suite and runs the test cases.
 *
 * This function is called once at the beginning of the test suite. It
 * initializes the Unity test framework and runs the test cases defined in the
 * suite.
 */
void setup() {
    // Join the I2C bus
    Wire.begin();
    
    UNITY_BEGIN();

    RUN_TEST(test_ble_module_begin);
    RUN_TEST(test_ble_module_advertise);


    UNITY_END();
}

void loop() {
    // Do nothing
}