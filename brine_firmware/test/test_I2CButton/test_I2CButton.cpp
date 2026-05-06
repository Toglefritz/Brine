#include <unity.h>

/*
 *  Test file for the I2CButton class. This test file tests the functionality of
 * the I2CButton class by asking the user to press the button. If the button is
 * pressed, the test passes. If the button is not pressed within one minute, the
 *  test fails.
 *
 *  Run this test with the command `pio test -e seeed_xiao_esp32c3 --filter test_I2CButton`.
 */

// Include necessary libraries and headers
#include <Arduino.h>
#include <I2CButton.h>
#include "test_I2CButton.h"

// I2C pins are defined in platformio.ini build flags
// Use I2C_SDA_PIN and I2C_SCL_PIN from build configuration

// The I2C interface for this test.
TwoWire mainI2C = TwoWire(0);

/**
 * @brief Test the initialization of the button.
 *
 * This function tests whether the button initializes correctly by calling the
 * `begin` method of the `I2CButton` class. It asserts that the `begin` method
 * returns true, indicating a successful initialization.
 */
void test_button_initialization(void) { test_button_initialization(mainI2C); } 

void setup() {
    // Initialize the custom I2C instance with pins from build configuration
    mainI2C.begin(I2C_SDA_PIN, I2C_SCL_PIN);

    // Start the Unity test framework
    UNITY_BEGIN();

    // Record the current time used for a test timeout
    startTime = millis();

    RUN_TEST(test_button_initialization);
    RUN_TEST(test_button_press);
}

void loop() {
    checkOneMinutePassed();

    // Check if either the button has been pressed or the timeout has occurred
    if (buttonPressed || testTimedOut) {
        // End the Unity test framework
        UNITY_END();
    }
}