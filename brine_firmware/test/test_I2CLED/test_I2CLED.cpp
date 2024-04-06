#include <unity.h>
#include "TestI2CLED.h"

/*
 *  This test file tests the I2CLED class. The I2CLED class is a singleton class that controls an LED connected to an
 *  I2C bus. The I2CLED class has two methods: turnOn() and turnOff(). The turnOn() method turns the LED on, and the
 *  turnOff() method turns the LED off. This test file tests the functionality of the I2CLED class by turning the LED on
 *  and off and asking the user to verify that the LED is on and off.
 *
 *  Run this test with the command `pio test --filter test_I2CLED`.
 */

void test_function_testLedControl(void)
{
    TestI2CLED testI2CLED;
    testI2CLED.testLedControl();
}

/**
 * @brief Initializes the test environment and runs the Unity test framework.
 *
 * This function is called once at the beginning of the test program. It allows some time for the serial port to
 * initialize, starts the Unity test framework, and runs the test function "test_function_testLedControl". Finally,
 * it ends the Unity test framework.
 */
void setup()
{
    // Initialize the Serial object
    Serial.begin(115200);

    // Allow some time for the serial port to initialize
    delay(5000);

    // Start the Unity test framework
    UNITY_BEGIN();

    RUN_TEST(test_function_testLedControl);

    // End the Unity test framework
    UNITY_END();
}

void loop()
{
    // Do nothing
}