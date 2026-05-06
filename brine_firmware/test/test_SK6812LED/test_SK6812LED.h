#ifndef TEST_SK6812LED_H
#define TEST_SK6812LED_H

#include <unity.h>
#include <SK6812LED.h>

/*
 * Tests for the SK6812LED class. SK6812LED is a singleton that controls SK6812
 * addressable RGB LEDs connected to a GPIO pin. It provides color control,
 * brightness adjustment, and visual effects (blink, rainbow, breathe).
 *
 * These tests drive the LED and rely on visual verification of the output.
 *
 * Hardware Setup for XIAO ESP32-S3:
 * - Connect SK6812 VCC to 3.3V or 5V
 * - Connect SK6812 GND to GND
 * - Connect SK6812 DIN to the configured data pin (SK6812_DATA_PIN)
 *
 * Run this test with the command `pio test --filter test_SK6812LED`.
 */

/**
 * @brief Tests initialization of the SK6812 LED.
 */
void test_sk6812_initialization(uint16_t numLeds = 1) {
  TEST_ASSERT_TRUE(SK6812LED::getInstance().begin(numLeds));
}

/**
 * @brief Tests turning the LED on with default color.
 */
void test_sk6812_turn_on(void) {
  TEST_ASSERT_TRUE(SK6812LED::getInstance().turnOn());
  TEST_ASSERT_TRUE(SK6812LED::getInstance().getState());
}

/**
 * @brief Tests turning off the LED.
 */
void test_sk6812_turn_off(void) {
  TEST_ASSERT_TRUE(SK6812LED::getInstance().turnOff());
  TEST_ASSERT_FALSE(SK6812LED::getInstance().getState());
}

/**
 * @brief Tests setting LED color using RGB values.
 */
void test_sk6812_set_color_rgb(void) {
  // Test setting red color
  TEST_ASSERT_TRUE(SK6812LED::getInstance().setColor(255, 0, 0));
  SK6812LED::getInstance().turnOn();
  delay(1500);

  // Test setting green color
  TEST_ASSERT_TRUE(SK6812LED::getInstance().setColor(0, 255, 0));
  delay(1500);

  // Test setting blue color
  TEST_ASSERT_TRUE(SK6812LED::getInstance().setColor(0, 0, 255));
  delay(1500);

  // Test setting white color
  TEST_ASSERT_TRUE(SK6812LED::getInstance().setColor(255, 255, 255));
  delay(1500);
}

/**
 * @brief Tests setting LED color using CRGB objects.
 */
void test_sk6812_set_color_crgb(void) {
  TEST_ASSERT_TRUE(SK6812LED::getInstance().setColor(CRGB::Red));
  delay(1000);
  TEST_ASSERT_TRUE(SK6812LED::getInstance().setColor(CRGB::Green));
  delay(1000);
  TEST_ASSERT_TRUE(SK6812LED::getInstance().setColor(CRGB::Blue));
  delay(1000);
  TEST_ASSERT_TRUE(SK6812LED::getInstance().setColor(CRGB::White));
  delay(1000);

  // Test custom CRGB color (purple)
  TEST_ASSERT_TRUE(SK6812LED::getInstance().setColor(CRGB(128, 64, 192)));
  delay(1000);
}

/**
 * @brief Tests brightness control.
 */
void test_sk6812_brightness(void) {
  SK6812LED::getInstance().setColor(255, 255, 255);
  SK6812LED::getInstance().turnOn();

  TEST_ASSERT_TRUE(SK6812LED::getInstance().setBrightness(255)); // Full brightness
  TEST_ASSERT_TRUE(SK6812LED::getInstance().setBrightness(128)); // 50% brightness
  TEST_ASSERT_TRUE(SK6812LED::getInstance().setBrightness(32));  // ~12.5% brightness
  TEST_ASSERT_TRUE(SK6812LED::getInstance().setBrightness(5));   // Very dim
}

/**
 * @brief Tests the blink effect.
 */
void test_sk6812_blink_effect(void) {
  SK6812LED::getInstance().setColor(0, 255, 0); // Green
  SK6812LED::getInstance().setBrightness(64);

  unsigned long startTime = millis();
  unsigned long testDuration = 3000; // 3 seconds

  while (millis() - startTime < testDuration) {
    TEST_ASSERT_TRUE(SK6812LED::getInstance().blink(millis(), 250));
    delay(10);
  }
}

/**
 * @brief Tests the rainbow effect.
 */
void test_sk6812_rainbow_effect(void) {
  unsigned long startTime = millis();
  unsigned long testDuration = 2000; // 2 seconds

  while (millis() - startTime < testDuration) {
    TEST_ASSERT_TRUE(SK6812LED::getInstance().rainbow(millis(), 30));
    delay(10);
  }
}

/**
 * @brief Tests the breathing effect.
 */
void test_sk6812_breathing_effect(void) {
  SK6812LED::getInstance().setColor(0, 0, 255); // Blue

  unsigned long startTime = millis();
  unsigned long testDuration = 3000; // 3 seconds

  while (millis() - startTime < testDuration) {
    TEST_ASSERT_TRUE(SK6812LED::getInstance().breathe(millis(), 15));
    delay(10);
  }
}

/**
 * @brief Tests color retrieval functionality.
 */
void test_sk6812_get_color(void) {
  CRGB testColor = CRGB(100, 150, 200);
  SK6812LED::getInstance().setColor(testColor);

  CRGB retrievedColor = SK6812LED::getInstance().getCurrentColor();
  TEST_ASSERT_EQUAL_UINT8(testColor.r, retrievedColor.r);
  TEST_ASSERT_EQUAL_UINT8(testColor.g, retrievedColor.g);
  TEST_ASSERT_EQUAL_UINT8(testColor.b, retrievedColor.b);
}

#endif
