#ifndef TEST_I2CLED_H
#define TEST_I2CLED_H

#include <Wire.h>
#include <Arduino.h>
#include <I2CLED.h>

/**
 * @class TestI2CLED
 * @brief Class for testing the LED control functionality.
 *
 * The `TestI2CLED` class provides a set of test functions to verify the LED control functionality. It allows the user to
 * test turning the LED on and off and verify the LED state.
 */
class TestI2CLED
{
public:
    /**
     * @brief Constructs a new instance of the TestI2CLED class.
     */
    TestI2CLED()
    {
        setup();
    }

    /**
     * @brief Tests the LED control functionality.
     *
     * This function turns the LED on, asks the user to verify that the LED is on,
     * then turns the LED off and asks the user to verify that the LED is off.
     */
    void testLedControl()
    {
        // Ask the tester to verify that the LED is off
        Serial.println("Please verify that the LED is currently off and then type 'y' to continue or 'n' to fail the test.");
        while (Serial.available() == 0)
        {
            // Wait for the user to type 'yes'
        }

        // Read the response
        char response = Serial.read();
        if (response != 'y')
        {
            // If the response is not 'y', print an error message and return
            Serial.println("Error: LED is not off. LED starting state test failed.");
            return;
        }
        else
        {
            // If the response is 'y', print a success message
            Serial.println("LED initialized correctly. LED starting state test passed.");
        }

        // Turn the LED on
        led.turnOn();
        // Ask the tester to verify that the LED is on
        Serial.println("Please verify that the LED is on and then type 'y' to continue or 'n' to fail the test.");
        while (Serial.available() == 0)
        {
            // Wait for the user to type 'yes'
        }

        // Read the response
        response = Serial.read();
        if (response != 'y')
        {
            // If the response is not 'y', print an error message and return
            Serial.println("Error: LED is not on. LED on test failed.");
            return;
        }
        else
        {
            // If the response is 'y', print a success message
            Serial.println("LED is on. LED on test passed.");
        }

        // Turn the LED off
        led.turnOff();
        // Ask the user to verify that the LED is off
        Serial.println("Please verify that the LED is off and then type 'y' to continue or 'n' to fail the test.");
        while (Serial.available() == 0)
        {
            // Wait for the user to type 'yes'
        }

        // Read the response
        response = Serial.read();
        if (response != 'y')
        {
            // If the response is not 'y', print an error message and return
            Serial.println("Error: LED is not off. LED off test failed.");
            return;
        }
        else
        {
            // If the response is 'y', print a success message
            Serial.println("LED is off. LED off test passed.");
        }

        // If the user verified that the LED is on and off, print a success message
        Serial.println("All LED control tests passed!");
    }

private:
    I2CLED &led = I2CLED::getInstance();

    /**
     * @brief Performs the setup for the test.
     *
     * This function joins the I2C bus, initializes the I2CLED, and prints a message to indicate that the I2CLED has been initialized.
     */
    void setup()
    {
        // Join I2C bus
        Wire.begin();

        // Initialize the I2CLED
        led.begin();

        // Print a message to indicate that the I2CLED has been initialized
        Serial.println("-----------------------------");
        Serial.println("Starting LED control tests.");
        Serial.println("-----------------------------");
    }
};

#endif // TEST_I2CLED_H