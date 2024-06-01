#include <unity.h>

/*
 *  Test file for the I2CButton class. This test file tests the functionality of
 * the I2CButton class by asking the user to press the button. If the button is
 * pressed, the test passes. If the button is not pressed within one minute, the
 *  test fails.
 *
 *  Run this test with the command `pio test --filter test_I2CButton`.
 */

// Include necessary libraries and headers
#include <Arduino.h>
#include <I2CButton.h>

// The start time of the sketch, which is used to create a timeout condition for
// the test that is used as a failure condition.
unsigned long startTime = millis();

// Determines if the button was pressed.
bool buttonPressed = false;

// A timeout duration for the test, in milliseconds.
unsigned long timeoutDuration = 30000;

// Determines if the test has timed out due to the button not being pressed.
bool testTimedOut = false;

/**
 * @brief The button handler function.
 *
 * This function is called when the button is pressed. It sets the
 * `buttonPressed` variable to true, indicating that the button was pressed.
 */
void buttonHandler() {
    buttonPressed = true;

    // End the test with a success message.
    TEST_PASS();
}

/**
 * @brief Test the initialization of the button.
 *
 * This function tests whether the button initializes correctly by calling the
 * `begin` method of the `I2CButton` class. It asserts that the `begin` method
 * returns true, indicating a successful initialization.
 */
void test_button_initialization() {
    // Test that the button initializes correctly
    TEST_ASSERT_TRUE(I2CButton::getInstance().begin(buttonHandler));
}

/**
 * @brief Test the button press functionality.
 *
 * This function is used to test the button press functionality. It displays a
 * message instructing the user to press the button in order to pass the test.
 */
void test_button_press() {
    TEST_IGNORE_MESSAGE("This test is interactive. Please press the button.");
}

/**
 * Checks if one minute has passed since the start time and the button has not
 * been pressed. If one minute has passed and the button has not been pressed,
 * the Unity test framework is ended with a failure message.
 */
void checkOneMinutePassed() {
    // If one minute has passed since the start time
    if (millis() - startTime >= timeoutDuration && !buttonPressed) {
        // Reset the start time
        startTime = millis();

        // Set the timeout flag
        testTimedOut = true;

        // End the Unity test framework
        TEST_FAIL_MESSAGE(
            "The button was not pressed within the test timeout. Test failed.");
    }
}

void setup() {
    // Join the I2C bus
    Wire.begin();

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