#include <unity.h>

/*
 *  Test file for the I2CButton class. This test file tests the functionality of the I2CButton class by asking the user
 *  to press the button. If the button is pressed, the test passes. If the button is not pressed within one minute, the
 *  test fails.
 *
 *  Run this test with the command `pio test --filter test_I2CButton`.
 */

// Include necessary libraries and headers
#include <Arduino.h>
#include <I2CButton.h>
#include "TestI2CButton.h"

// The start time of the sketch, which is used to create a timeout condition for the test that is used as a
// failure condition.
unsigned long startTime = millis();

// Determines if the button was pressed.
bool buttonPressed = false;

// Test function
//
// This function tests the functionality of the I2CButton class. This function is used as a callback when the button is
// pressed. The buton uses an interrupt to call this function. Therefore, if this function is called, both the button
// and the interrupt are working correctly.
void testButton()
{
    buttonPressed = true;

    // If the response is 'y', print a success message
    Serial.println("Button was pressed. Button press test passed.");

    // End the Unity test framework
    UNITY_END();
}

void test_function_testLedControl(void)
{
    TestI2CButton testI2CButton(testButton);
    testI2CButton.testButton();
}

// Function to check if one minute has passed since the start time. If one minute has passed, and the button was not
// pressed, the test has failed.
void checkOneMinutePassed()
{
    // If one minute has passed since the start time
    if (millis() - startTime >= 60000 && !buttonPressed)
    {
        // Reset the start time
        startTime = millis();

        // Print a message to indicate that the test has failed
        Serial.println("One minute has passed without button press. Test failed.");

        // TODO(Toglefritz): Fail the test
        // End the Unity test framework
        UNITY_END();
    }
}

void setup()
{
    // Initialize the Serial object
    Serial.begin(115200);

    // Allow some time for the serial port to initialize
    delay(5000);

    // Start the Unity test framework
    UNITY_BEGIN();

    // Record the current time used for a test timeout
    startTime = millis();

    RUN_TEST(test_function_testLedControl);
}

void loop()
{
    checkOneMinutePassed();
}