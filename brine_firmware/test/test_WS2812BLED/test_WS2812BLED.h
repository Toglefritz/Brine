#ifndef TEST_WS2812BLED_H
#define TEST_WS2812BLED_H

#include <unity.h>
#include <WS2812BLED.h>

/*
 *  This test file tests the WS2812BLED class. The WS2812BLED class is a singleton class
 * that controls WS2812B RGB LEDs connected to a GPIO pin. The WS2812BLED class provides
 * methods for color control, brightness adjustment, and various effects including
 * turnOn(), turnOff(), setColor(), setBrightness(), blink(), rainbow(), and breathe().
 * This test file tests the functionality of the WS2812BLED class by controlling the LED
 * and asking the user to verify the visual output.
 *
 *  Run this test with the command `pio test --filter test_WS2812BLED`.
 */

/**
 * @brief Tests initialization of the WS2812B LED.
 */
void test_ws2812b_initialization(uint16_t numLeds = 1) {
  // Test that the LED initializes correctly
  TEST_ASSERT_TRUE(WS2812BLED::getInstance().begin(numLeds));
}

/**
 * @brief Tests turning the LED on with default color.
 */
void test_ws2812b_turn_on(void) {
  // Test that the LED turns on correctly
  TEST_ASSERT_TRUE(WS2812BLED::getInstance().turnOn());
  
  // Verify the LED state
  TEST_ASSERT_TRUE(WS2812BLED::getInstance().getState());
}

/**
 * @brief Tests turning off the LED.
 */
void test_ws2812b_turn_off(void) {
  // Test that the LED turns off correctly
  TEST_ASSERT_TRUE(WS2812BLED::getInstance().turnOff());
  
  // Verify the LED state
  TEST_ASSERT_FALSE(WS2812BLED::getInstance().getState());
}

/**
 * @brief Tests setting LED color using RGB values.
 */
void test_ws2812b_set_color_rgb(void) {
  // Test setting red color
  TEST_ASSERT_TRUE(WS2812BLED::getInstance().setColor(255, 0, 0));
  WS2812BLED::getInstance().turnOn();
  
  // Test setting green color
  TEST_ASSERT_TRUE(WS2812BLED::getInstance().setColor(0, 255, 0));
  
  // Test setting blue color
  TEST_ASSERT_TRUE(WS2812BLED::getInstance().setColor(0, 0, 255));
  
  // Test setting white color
  TEST_ASSERT_TRUE(WS2812BLED::getInstance().setColor(255, 255, 255));
}

/**
 * @brief Tests setting LED color using CRGB objects.
 */
void test_ws2812b_set_color_crgb(void) {
  // Test setting predefined colors
  TEST_ASSERT_TRUE(WS2812BLED::getInstance().setColor(CRGB::Red));
  TEST_ASSERT_TRUE(WS2812BLED::getInstance().setColor(CRGB::Green));
  TEST_ASSERT_TRUE(WS2812BLED::getInstance().setColor(CRGB::Blue));
  TEST_ASSERT_TRUE(WS2812BLED::getInstance().setColor(CRGB::White));
  
  // Test custom CRGB color
  TEST_ASSERT_TRUE(WS2812BLED::getInstance().setColor(CRGB(128, 64, 192)));
}

/**
 * @brief Tests brightness control.
 */
void test_ws2812b_brightness(void) {
  // Set a visible color first
  WS2812BLED::getInstance().setColor(255, 255, 255);
  WS2812BLED::getInstance().turnOn();
  
  // Test different brightness levels
  TEST_ASSERT_TRUE(WS2812BLED::getInstance().setBrightness(255)); // Full brightness
  TEST_ASSERT_TRUE(WS2812BLED::getInstance().setBrightness(128)); // 50% brightness
  TEST_ASSERT_TRUE(WS2812BLED::getInstance().setBrightness(32));  // ~12.5% brightness
  TEST_ASSERT_TRUE(WS2812BLED::getInstance().setBrightness(5));   // Very dim
}

/**
 * @brief Tests the blink effect.
 */
void test_ws2812b_blink_effect(void) {
  // Set a visible color
  WS2812BLED::getInstance().setColor(0, 255, 0); // Green
  WS2812BLED::getInstance().setBrightness(64);
  
  // Test blink functionality over several cycles
  unsigned long startTime = millis();
  unsigned long testDuration = 3000; // 3 seconds
  
  while (millis() - startTime < testDuration) {
    TEST_ASSERT_TRUE(WS2812BLED::getInstance().blink(millis(), 250)); // Blink every 250ms
    delay(10);
  }
}

/**
 * @brief Tests the rainbow effect.
 */
void test_ws2812b_rainbow_effect(void) {
  // Test rainbow effect for a short duration
  unsigned long startTime = millis();
  unsigned long testDuration = 2000; // 2 seconds
  
  while (millis() - startTime < testDuration) {
    TEST_ASSERT_TRUE(WS2812BLED::getInstance().rainbow(millis(), 30)); // Fast rainbow
    delay(10);
  }
}

/**
 * @brief Tests the breathing effect.
 */
void test_ws2812b_breathing_effect(void) {
  // Set a color for breathing effect
  WS2812BLED::getInstance().setColor(0, 0, 255); // Blue
  
  // Test breathing effect for a short duration
  unsigned long startTime = millis();
  unsigned long testDuration = 3000; // 3 seconds
  
  while (millis() - startTime < testDuration) {
    TEST_ASSERT_TRUE(WS2812BLED::getInstance().breathe(millis(), 15)); // Smooth breathing
    delay(10);
  }
}

/**
 * @brief Tests color retrieval functionality.
 */
void test_ws2812b_get_color(void) {
  // Set a known color
  CRGB testColor = CRGB(100, 150, 200);
  WS2812BLED::getInstance().setColor(testColor);
  
  // Retrieve and verify the color
  CRGB retrievedColor = WS2812BLED::getInstance().getCurrentColor();
  TEST_ASSERT_EQUAL_UINT8(testColor.r, retrievedColor.r);
  TEST_ASSERT_EQUAL_UINT8(testColor.g, retrievedColor.g);
  TEST_ASSERT_EQUAL_UINT8(testColor.b, retrievedColor.b);
}

#endif