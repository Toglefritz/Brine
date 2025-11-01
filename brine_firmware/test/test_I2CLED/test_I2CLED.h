#ifndef TEST_I2CLED_H
#define TEST_I2CLED_H

#include <unity.h>
#include <I2CLED.h>
#include <Wire.h>

/*
 * This test file tests the I2CLED class. The I2CLED class is a singleton class
 * that controls an LED connected to an I2C bus. The I2CLED class has two
 * methods: turnOn() and turnOff(). The turnOn() method turns the LED on, and
 * the turnOff() method turns the LED off. This test file tests the
 * functionality of the I2CLED class by turning the LED on and off and asking
 * the user to verify that the LED is on and off.
 *
 *  Run this test with the command `pio test --filter test_I2CLED`.
 */

/**
 * @brief Tests initialization of the I2C LED.
 */
void test_led_initialization(TwoWire &i2cBus) {
  // Test that the LED initializes correctly
  TEST_ASSERT_TRUE(I2CLED::getInstance().begin(i2cBus));
}

/**
 * @brief Tests turning the LED on.
 */
void test_led_turn_on(void) {
  // Test that the LED turns on correctly
  I2CLED::getInstance().turnOn();

  TEST_ASSERT_TRUE(I2CLED::getInstance().turnOn());
}

/**
 * @brief Tests turning off the LED.
 */
void test_led_turn_off(void) {
  // Test that the LED turns off correctly
  I2CLED::getInstance().turnOff();

  TEST_ASSERT_TRUE(I2CLED::getInstance().turnOff());
}

#endif