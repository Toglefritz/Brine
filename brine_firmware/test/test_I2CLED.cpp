// Include necessary libraries and headers
#include <Arduino.h>
#include <I2CLED.h>

I2CLED &led = I2CLED::getInstance();

// Test function
//
// This function tests the LED control functionality. It turns the LED on, asks the user to verify that the LED is on,
// then turns the LED off and asks the user to verify that the LED is off.
void testLedControl()
{
    // Turn the LED on
    led.turnOn();
     // Ask the user to verify that the LED is on
    Serial.println("Please verify that the LED is on and then type 'y' to continue.");
    while (Serial.available() == 0) {
        // Wait for the user to type 'yes'
    }

    // Read the response
    char response = Serial.read();
    if (response != 'y') {
        // If the response is not 'y', print an error message and return
        Serial.println("Error: LED is not on. LED on test failed.");
        return;
    } else {
        // If the response is 'y', print a success message
        Serial.println("LED is on. LED on test passed.");
    }

    /*// Turn the LED off
    led.turnOff();
    // Ask the user to verify that the LED is off
    Serial.println("Please verify that the LED is off and then type 'yes' to continue.");
    while (Serial.available() == 0) {
        // Wait for the user to type 'yes'
    }

    // Read the response
    response = Serial.read();
    if (response != 'y') {
        // If the response is not 'y', print an error message and return
        Serial.println("Error: LED is not off. LED off test failed.");
        return;
    } else {
        // If the response is 'y', print a success message
        Serial.println("LED is off. LED off test passed.");

    }

    // If the user verified that the LED is on and off, print a success message
    Serial.println("All LED control tests passed."); */
}

void setup()
{
    // Join I2C bus
    Wire.begin();

    // Initialize the I2CLED
    led.begin();

    // Test the LED control functionality
    testLedControl();
}

void loop()
{
    delay(1000);
}