#include "test_GPIOButton.h"
#include <GPIOButton.h>
#include <unity.h>

/*
 * This test file tests the GPIOButton class. The GPIOButton class is a singleton class
 * that controls a button connected directly to a GPIO pin. The button should be wired
 * between the GPIO pin and GND, with the internal pull-up resistor providing the HIGH
 * state when the button is not pressed.
 *
 * Hardware Setup for ESP32-S3:
 * - Connect one side of the button to GPIO8 (or pin specified by GPIO_BUTTON_PIN)
 * - Connect the other side of the button to GND
 * - No external pull-up resistor needed (internal pull-up is used)
 *
 *  Run this test with the command `pio test --filter test_GPIOButton`.
 */

// Test state variables
unsigned long startTime = 0;
bool buttonPressed = false;
bool testTimedOut = false;
unsigned long timeoutDuration = 30000; // 30 seconds timeout
volatile bool interruptTriggered = false;

/**
 * @brief Simple interrupt handler for testing.
 */
void IRAM_ATTR test_button_isr() {
    interruptTriggered = true;
    buttonPressed = true;
}

/**
 * @brief Tests initialization of the GPIO button.
 */
void test_button_initialization(void) {
    test_gpiobutton_initialization();
}

/**
 * @brief Tests button press detection with user interaction.
 */
void test_button_press_detection(void) {
    TEST_IGNORE_MESSAGE("This test is interactive. Please press the GPIO button connected to pin 8 to pass this test.");
}

/**
 * @brief Tests interrupt functionality with user interaction.
 */
void test_button_interrupt_functionality(void) {
    // Attach interrupt for testing
    GPIOButton::getInstance().attachInterrupt(test_button_isr, FALLING);
    TEST_IGNORE_MESSAGE("Interrupt attached. Please press the GPIO button to trigger the interrupt and pass this test.");
}

/**
 * @brief Tests clearing event bits.
 */
void test_button_clear_events(void) {
    test_gpiobutton_clear_events();
}

/**
 * @brief Tests deep sleep wake-up configuration.
 */
void test_button_deep_sleep_config(void) {
    test_gpiobutton_deep_sleep_wakeup();
}

/**
 * @brief Tests pin number retrieval.
 */
void test_button_pin_retrieval(void) {
    test_gpiobutton_get_pin();
}

/**
 * @brief Checks if the timeout has passed and handles test completion.
 */
void checkTimeoutPassed() {
    // If timeout has passed and button has not been pressed
    if (millis() - startTime >= timeoutDuration && !buttonPressed) {
        testTimedOut = true;
        TEST_FAIL_MESSAGE("The GPIO button was not pressed within the test timeout. Test failed.");
    }
}

/**
 * @brief Initializes the test environment and runs the Unity test framework.
 */
void setup() {
    // Start the Unity test framework
    UNITY_BEGIN();

    // Record the current time for timeout tracking
    startTime = millis();

    // Run basic functionality tests
    RUN_TEST(test_button_initialization);
    RUN_TEST(test_button_pin_retrieval);
    RUN_TEST(test_button_clear_events);
    RUN_TEST(test_button_deep_sleep_config);
    
    // Run interactive tests that require user input
    RUN_TEST(test_button_press_detection);
    RUN_TEST(test_button_interrupt_functionality);
}

void loop() {
    checkTimeoutPassed();

    // Check if button was pressed (either directly or via interrupt)
    if (GPIOButton::getInstance().isPressed() || interruptTriggered) {
        if (!buttonPressed) {
            buttonPressed = true;
            TEST_PASS_MESSAGE("GPIO button press detected successfully!");
        }
    }

    // Check if either the button has been pressed or the timeout has occurred
    if (buttonPressed || testTimedOut) {
        // End the Unity test framework
        UNITY_END();
    }
}