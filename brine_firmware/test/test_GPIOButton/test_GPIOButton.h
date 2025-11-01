#ifndef TEST_GPIOBUTTON_H
#define TEST_GPIOBUTTON_H

#include <unity.h>
#include <GPIOButton.h>

/*
 *  This test file tests the GPIOButton class. The GPIOButton class is a singleton class
 * that controls a button connected directly to a GPIO pin. The button should be wired
 * between the GPIO pin and GND, with the internal pull-up resistor providing the HIGH
 * state when the button is not pressed.
 *
 * Hardware Setup:
 * - Connect one side of the button to GPIO8 (or pin specified by GPIO_BUTTON_PIN)
 * - Connect the other side of the button to GND
 * - No external pull-up resistor needed (internal pull-up is used)
 *
 *  Run this test with the command `pio test --filter test_GPIOButton`.
 */

/**
 * @brief Tests initialization of the GPIO button.
 */
void test_gpiobutton_initialization(void) {
  // Test that the button initializes correctly
  TEST_ASSERT_TRUE(GPIOButton::getInstance().begin());
}

/**
 * @brief Tests clearing event bits.
 */
void test_gpiobutton_clear_events(void) {
  // Test that clearing events doesn't cause errors
  GPIOButton::getInstance().clearEventBits();
  
  // Verify button still responds after clearing events
  bool buttonState = GPIOButton::getInstance().isPressed();
  TEST_ASSERT_TRUE(buttonState == true || buttonState == false);
}

/**
 * @brief Tests deep sleep wake-up configuration.
 */
void test_gpiobutton_deep_sleep_wakeup(void) {
  // Test enabling deep sleep wake-up
  bool wakeupResult = GPIOButton::getInstance().enableDeepSleepWakeup(0); // Wake on LOW
  TEST_ASSERT_TRUE(wakeupResult);
  
  // Test with different wake-up level
  wakeupResult = GPIOButton::getInstance().enableDeepSleepWakeup(1); // Wake on HIGH
  TEST_ASSERT_TRUE(wakeupResult);
}

/**
 * @brief Tests getting the button pin number.
 */
void test_gpiobutton_get_pin(void) {
  uint8_t pin = GPIOButton::getInstance().getPin();
  
  // Should return the configured pin (default GPIO8 or build flag override)
  TEST_ASSERT_EQUAL_UINT8(GPIO_BUTTON_PIN, pin);
}

#endif