#include "test_SK6812LED.h"
#include <SK6812LED.h>
#include <unity.h>

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

// Define number of LEDs for testing
#define NUM_LEDS 1

/**
 * @brief Prints an initial test setup message.
 */
void show_test_setup_message(void) {
    TEST_IGNORE_MESSAGE("Please observe the LED during testing for visual verification.");
}

/**
 * @brief Tests initialization of the SK6812 LED.
 */
void test_led_initialization(void) {
    test_sk6812_initialization(NUM_LEDS);
}

/**
 * @brief Tests turning the LED on.
 */
void test_led_turn_on(void) {
    test_sk6812_turn_on();
    TEST_IGNORE_MESSAGE("LED should be ON (white). Verify visually.");
}

/**
 * @brief Tests turning off the LED.
 */
void test_led_turn_off(void) {
    test_sk6812_turn_off();
    TEST_IGNORE_MESSAGE("LED should be OFF. Verify visually.");
}

/**
 * @brief Tests RGB color setting.
 */
void test_color_control_rgb(void) {
    test_sk6812_set_color_rgb();
    TEST_IGNORE_MESSAGE("LED should have cycled through Red -> Green -> Blue -> White. Verify visually.");
}

/**
 * @brief Tests CRGB color setting.
 */
void test_color_control_crgb(void) {
    test_sk6812_set_color_crgb();
    TEST_IGNORE_MESSAGE("LED should have shown various colors including a custom purple. Verify visually.");
}

/**
 * @brief Tests brightness control.
 */
void test_brightness_control(void) {
    test_sk6812_brightness();
    TEST_IGNORE_MESSAGE("LED should have shown different brightness levels. Verify visually.");
}

/**
 * @brief Tests blink effect.
 */
void test_blink_effect(void) {
    test_sk6812_blink_effect();
    TEST_IGNORE_MESSAGE("LED should have blinked green rapidly for 3 seconds. Verify visually.");
}

/**
 * @brief Tests rainbow effect.
 */
void test_rainbow_effect(void) {
    test_sk6812_rainbow_effect();
    TEST_IGNORE_MESSAGE("LED should have shown a smooth rainbow cycle for 2 seconds. Verify visually.");
}

/**
 * @brief Tests breathing effect.
 */
void test_breathing_effect(void) {
    test_sk6812_breathing_effect();
    TEST_IGNORE_MESSAGE("LED should have shown a blue breathing effect for 3 seconds. Verify visually.");
}

/**
 * @brief Tests color retrieval.
 */
void test_color_retrieval(void) {
    test_sk6812_get_color();
}

/**
 * @brief Prints a message when the test is complete.
 */
void show_test_complete_message(void) {
    TEST_IGNORE_MESSAGE("All tests completed. LED should be OFF.");
}

/**
 * @brief Initializes the test environment and runs the Unity test framework.
 *
 * Runs all SK6812 LED tests with visual verification instructions provided
 * through TEST_IGNORE_MESSAGE calls that appear in PlatformIO test output.
 */
void setup() {
    // Add startup delay to ensure system stability
    delay(2000);

    // Start the Unity test framework
    UNITY_BEGIN();

    RUN_TEST(show_test_setup_message);

    // Basic functionality tests
    RUN_TEST(test_led_initialization);
    delay(500);

    RUN_TEST(test_led_turn_on);
    delay(2000);

    RUN_TEST(test_led_turn_off);
    delay(1000);

    // Color control tests
    RUN_TEST(test_color_control_rgb);
    delay(2000);

    RUN_TEST(test_color_control_crgb);
    delay(2000);

    // Brightness control test
    RUN_TEST(test_brightness_control);
    delay(2000);

    // Effect tests
    RUN_TEST(test_blink_effect);
    delay(1000);

    RUN_TEST(test_rainbow_effect);
    delay(1000);

    RUN_TEST(test_breathing_effect);
    delay(1000);

    // Data integrity test
    RUN_TEST(test_color_retrieval);

    // Final cleanup
    SK6812LED::getInstance().turnOff();

    RUN_TEST(show_test_complete_message);

    // End the Unity test framework
    UNITY_END();
}

void loop() {
    // All tests run in setup()
}
