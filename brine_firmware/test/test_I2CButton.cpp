/*
*  Test file for the I2CButton class. This test file tests the functionality of the I2CButton class by asking the user
*  to press the button. If the button is pressed, the test passes. If the button is not pressed within one minute, the
*  test fails.
*
*  Run this test with the command `pio test -e env:test_button -f test_I2CButton.cpp`.
*/

// Include necessary libraries and headers
#include <Arduino.h>
#include <I2CButton.h>

I2CButton &button = I2CButton::getInstance();

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
}

// Function to check if one minute has passed since the start time. If one minute has passed, and the button was not
// pressed, the test has failed.
void checkOneMinutePassed() {
    // If one minute has passed since the start time
    if (millis() - startTime >= 60000 && !buttonPressed)
    {
        // Reset the start time
        startTime = millis();

        // Print a message to indicate that the test has failed
        Serial.println("One minute has passed without button press. Test failed.");

        while (1); // Freeze!
    }
}

void setup() {
    // Join I2C bus
    Wire.begin();

    // Initialize the I2CButton and set the testButton function as the callback
    button.begin(testButton);

    // Print a message to indicate that the I2CLED has been initialized
    Serial.println("-----------------------------");
    Serial.println("Starting button tests.");
    Serial.println("-----------------------------");

    startTime = millis();

    // Ask the tester to press the button
    Serial.println("Please press the button.");

    // After the sketch has been running for 1 minute, print a message to indicate that the test has failed.
}

void loop()
{
    checkOneMinutePassed();
}