// ButtonTester.h
#ifndef BUTTON_TESTER_H
#define BUTTON_TESTER_H

#include <Wire.h>
#include <Arduino.h>
#include <I2CButton.h>

class TestI2CButton
{
public:
    /**
     * @brief Constructs a new instance of the TestI2CLED class.
     */
    TestI2CButton(void (*buttonHandler)())
    {
        setup(buttonHandler);
    }

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

private:
    I2CButton &button = I2CButton::getInstance();

    // Determines if the button was pressed.
    bool buttonPressed = false;

    /**
     * @brief Performs the setup for the test.
     *
     * This function joins the I2C bus, initializes the I2CButton, and prints a message to indicate that the I2CButton
     * has been initialized.
     */
    void setup(void (*buttonHandler)())
    {
        // Join I2C bus
        Wire.begin();

        // Initialize the I2CButton and set the testButton function as the callback
        button.begin(buttonHandler);

        // Print a message to indicate that the I2CLED has been initialized
        Serial.println("-----------------------------");
        Serial.println("Starting button tests.");
        Serial.println("-----------------------------");

        // Ask the tester to press the button
        Serial.println("Please press the button.");
    }
};

#endif