#include <unity.h>
#include <Wire.h>
#include <I2CLED.h>

/*
 *  This test file tests the I2CLED class. The I2CLED class is a singleton class that controls an LED connected to an
 *  I2C bus. The I2CLED class has two methods: turnOn() and turnOff(). The turnOn() method turns the LED on, and the
 *  turnOff() method turns the LED off. This test file tests the functionality of the I2CLED class by turning the LED on
 *  and off and asking the user to verify that the LED is on and off.
 *
 *  Run this test with the command `pio test --filter test_I2CLED`.
 */

void test_led_initialization(void)
{
    // Test that the LED initializes correctly
    TEST_ASSERT_TRUE(I2CLED::getInstance().begin());
}

void test_led_turn_on(void)
{
    // Test that the LED turns on correctly
    I2CLED::getInstance().turnOn();

    TEST_ASSERT_TRUE(I2CLED::getInstance().turnOn());
}

void test_led_turn_off(void)
{
    // Test that the LED turns off correctly
    I2CLED::getInstance().turnOff();

    TEST_ASSERT_TRUE(I2CLED::getInstance().turnOff());
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
    // Join the I2C bus
    Wire.begin();

    // Start the Unity test framework
    UNITY_BEGIN();

    RUN_TEST(test_led_initialization);
    RUN_TEST(test_led_turn_on);
    delay(1000); // Short delay allowing human tester to more easily verify LED state visually
    RUN_TEST(test_led_turn_off);

    // End the Unity test framework
    UNITY_END();
}

void loop()
{
    // Do nothing
}