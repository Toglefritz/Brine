#include "test_I2CLED.h"
#include <I2CLED.h>
#include <Wire.h>
#include <unity.h>

/*
 *  This test file tests the I2CLED class. The I2CLED class is a singleton class
 * that controls an LED connected to an I2C bus. The I2CLED class has two
 * methods: turnOn() and turnOff(). The turnOn() method turns the LED on, and
 * the turnOff() method turns the LED off. This test file tests the
 * functionality of the I2CLED class by turning the LED on and off and asking
 * the user to verify that the LED is on and off.
 *
 *  Run this test with the command `pio test -e seeed_xiao_esp32c3 --filter test_I2CLED`.
 */

// I2C pins are defined in platformio.ini build flags
// Use I2C_SDA_PIN and I2C_SCL_PIN from build configuration

// The I2C interface for this test.
TwoWire mainI2C = TwoWire(0);

/**
 * @brief Tests initialization of the I2C LED.
 */
void test_led_initialization(void) { test_led_initialization(mainI2C); }

/**
 * @brief Initializes the test environment and runs the Unity test framework.
 *
 * This function is called once at the beginning of the test program. It allows
 * some time for the serial port to initialize, starts the Unity test framework,
 * and runs the test function "test_function_testLedControl". Finally, it ends
 * the Unity test framework.
 */
void setup() {
  // Initialize the custom I2C instance with pins from build configuration
  mainI2C.begin(I2C_SDA_PIN, I2C_SCL_PIN);

  // Start the Unity test framework
  UNITY_BEGIN();

  RUN_TEST(test_led_initialization);
  RUN_TEST(test_led_turn_on);
  delay(1000); // Short delay allowing human tester to more easily verify LED
               // state visually
  RUN_TEST(test_led_turn_off);

  // End the Unity test framework
  UNITY_END();
}

void loop() {
  // Do nothing
}