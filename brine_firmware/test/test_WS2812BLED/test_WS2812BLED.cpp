#include "test_WS2812BLED.h"
#include <WS2812BLED.h>
#include <unity.h>

/*
 *  This test file tests the WS2812BLED class. The WS2812BLED class is a singleton class
 * that controls WS2812B RGB LEDs connected to a GPIO pin. The WS2812BLED class provides
 * methods for color control, brightness adjustment, and various effects including
 * turnOn(), turnOff(), setColor(), setBrightness(), blink(), rainbow(), and breathe().
 * This test file tests the functionality of the WS2812BLED class by controlling the LED
 * and asking the user to verify the visual output.
 *
 * Hardware Setup for XIAO ESP32-S3:
 * - Connect WS2812B VCC to 3.3V or 5V
 * - Connect WS2812B GND to GND
 * - Connect WS2812B DIN to GPIO1 (D0/A0 pin on XIAO ESP32-S3)
 *
 *  Run this test with the command `pio test --filter test_WS2812BLED`.
 */

// Define number of LEDs for testing
#define NUM_LEDS 1

// WS2812B_DATA_PIN is defined in the library header (default: GPIO1/D0/A0 for XIAO ESP32-S3)
// Can be overridden with build flags if needed

/**
 * @brief Tests initialization of the WS2812B LED.
 */
void test_led_initialization(void) { 
    test_ws2812b_initialization(NUM_LEDS); 
}

/**
 * @brief Tests turning the LED on.
 */
void test_led_turn_on(void) {
    test_ws2812b_turn_on();
}

/**
 * @brief Tests turning off the LED.
 */
void test_led_turn_off(void) {
    test_ws2812b_turn_off();
}

/**
 * @brief Tests RGB color setting.
 */
void test_color_control_rgb(void) {
    test_ws2812b_set_color_rgb();
}

/**
 * @brief Tests CRGB color setting.
 */
void test_color_control_crgb(void) {
    test_ws2812b_set_color_crgb();
}

/**
 * @brief Tests brightness control.
 */
void test_brightness_control(void) {
    test_ws2812b_brightness();
}

/**
 * @brief Tests blink effect.
 */
void test_blink_effect(void) {
    test_ws2812b_blink_effect();
}

/**
 * @brief Tests rainbow effect.
 */
void test_rainbow_effect(void) {
    test_ws2812b_rainbow_effect();
}

/**
 * @brief Tests breathing effect.
 */
void test_breathing_effect(void) {
    test_ws2812b_breathing_effect();
}

/**
 * @brief Tests color retrieval.
 */
void test_color_retrieval(void) {
    test_ws2812b_get_color();
}

/**
 * @brief Initializes the test environment and runs the Unity test framework.
 *
 * This function is called once at the beginning of the test program. It allows
 * some time for the serial port to initialize, starts the Unity test framework,
 * and runs all test functions. The tests include visual verification steps
 * where the human tester should observe the LED behavior.
 */
void setup() {
    // Allow time for serial port to initialize
    delay(2000);
    
    Serial.begin(115200);
    Serial.println("\n=== WS2812B LED Hardware-in-the-Loop Test ===");
    Serial.println("Please observe the LED during testing for visual verification.");
    Serial.println("The LED should be connected to GPIO pin " + String(WS2812B_DATA_PIN));
    Serial.println("Starting tests in 3 seconds...\n");
    
    delay(3000);

    // Start the Unity test framework
    UNITY_BEGIN();

    // Basic functionality tests
    Serial.println("\n--- Testing Basic Functionality ---");
    RUN_TEST(test_led_initialization);
    delay(500);
    
    RUN_TEST(test_led_turn_on);
    Serial.println("LED should be ON (white). Verify visually.");
    delay(2000);
    
    RUN_TEST(test_led_turn_off);
    Serial.println("LED should be OFF. Verify visually.");
    delay(1000);

    // Color control tests
    Serial.println("\n--- Testing Color Control ---");
    RUN_TEST(test_color_control_rgb);
    Serial.println("LED should have cycled through Red -> Green -> Blue -> White. Verify visually.");
    delay(2000);
    
    RUN_TEST(test_color_control_crgb);
    Serial.println("LED should have shown various colors including a custom purple. Verify visually.");
    delay(2000);

    // Brightness control test
    Serial.println("\n--- Testing Brightness Control ---");
    RUN_TEST(test_brightness_control);
    Serial.println("LED should have shown different brightness levels. Verify visually.");
    delay(2000);

    // Effect tests
    Serial.println("\n--- Testing Effects ---");
    Serial.println("Testing blink effect (3 seconds)...");
    RUN_TEST(test_blink_effect);
    Serial.println("LED should have blinked green rapidly. Verify visually.");
    delay(1000);
    
    Serial.println("Testing rainbow effect (2 seconds)...");
    RUN_TEST(test_rainbow_effect);
    Serial.println("LED should have shown a smooth rainbow cycle. Verify visually.");
    delay(1000);
    
    Serial.println("Testing breathing effect (3 seconds)...");
    RUN_TEST(test_breathing_effect);
    Serial.println("LED should have shown a blue breathing effect. Verify visually.");
    delay(1000);

    // Data integrity test
    Serial.println("\n--- Testing Data Integrity ---");
    RUN_TEST(test_color_retrieval);
    Serial.println("Color retrieval test completed.");

    // Final cleanup
    WS2812BLED::getInstance().turnOff();
    Serial.println("\nAll tests completed. LED should be OFF.");

    // End the Unity test framework
    UNITY_END();
}

void loop() {
    // Do nothing - all tests run in setup()
}