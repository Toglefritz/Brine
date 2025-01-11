#include <Arduino.h>
#include <Wire.h>
#include <unity.h>

// Include the header files for each individual test
#include "../test_I2CButton/test_I2CButton.h"
#include "../test_I2CLED/test_I2CLED.h"
#include "../test_I2CScanner/test_I2CScanner.h"
#include "../test_NVSService/test_NVSService.h"
#include "../test_BatteryMonitor/test_BatteryMonitor.h"
#include "../test_BLEModule/test_BLEModule.h"
#include "../test_CryptoService/test_CryptoService.h"

/*
 * This file combines all separate tests into a single test run by including the
 * header files for each individual test. Each header file contains the test
 * functions specific to a hardware component or feature of the Brine IoT device.
 *
 * By combining the tests into a single sketch, this approach allows all tests
 * to be built and uploaded at once, eliminating the time-consuming process of
 * separately building and uploading each individual test file.
 *
 * Once built and uploaded, the combined test will sequentially execute all
 * the test functions from the included headers, providing a complete test
 * suite for the device in a single run.
 *
 * To run this combined test, use the command, `pio test --filter test_FullSystem`
 */

// Define pins for the main I2C bus
#define MAIN_SDA_PIN 21
#define MAIN_SCL_PIN 22

// The I2C interface for this test.
TwoWire mainI2C = TwoWire(0);

// Define pins for the main I2C bus
#define CRYPTO_SDA_PIN 19
#define CRYPTO_SCL_PIN 18

// The I2C interface for this test.
TwoWire cryptoI2C = TwoWire(1);

// Declare helper functions for tests requiring arguments. Functions within
// calls to RUN_TEST must be void, so these helper functions allow arguments to
// be passed to these functions.
void test_button_initialization(void) { test_button_initialization(mainI2C); }
void test_led_initialization(void) { test_led_initialization(mainI2C); }
void test_main_I2C_devices_detected(void) { test_main_I2C_devices_detected(mainI2C); }
void test_crypto_I2C_devices_detected(void) { test_crypto_I2C_devices_detected(mainI2C); }
void test_battery_life_percentage(void) { test_battery_life_percentage(mainI2C); }
void test_crypto_service_begin(void) { test_crypto_service_begin(cryptoI2C); }

void setup() {
  // Initialize the I2C busses for the main instances
  mainI2C.begin(MAIN_SDA_PIN, MAIN_SCL_PIN);
  cryptoI2C.begin(CRYPTO_SDA_PIN, CRYPTO_SCL_PIN);

  // Start Unity framework
  UNITY_BEGIN();

  // I2C scanner tests
  RUN_TEST(test_main_I2C_devices_detected);
  RUN_TEST(test_crypto_I2C_devices_detected);

  // I2C LED tests
  RUN_TEST(test_led_initialization);
  RUN_TEST(test_led_turn_on);
  delay(1000); // Allow for visual verification
  RUN_TEST(test_led_turn_off);

  // NVS tests
  RUN_TEST(test_nvs_initialization);
  RUN_TEST(test_save_json);
  RUN_TEST(test_retrieve_json);
  RUN_TEST(test_nvs_initialization);
  RUN_TEST(test_erase_key);
  RUN_TEST(test_erase_all);

  // Battery monitor tests
  RUN_TEST(test_battery_life_percentage);

  // BLE module tests
  RUN_TEST(test_ble_module_begin);
  RUN_TEST(test_ble_module_advertise);

  // Cryptographic coprocessor tests
  RUN_TEST(test_crypto_service_begin);
  RUN_TEST(test_crypto_service_read_public_key);
  RUN_TEST(test_crypto_service_sign_request);

  // I2C button tests
  startTime = millis();
  RUN_TEST(test_button_initialization);
  // This test must be last so that the test will wait to complete until the button is pressed.
  RUN_TEST(test_button_press);
}

void loop() {
  checkOneMinutePassed();

  // Check if either the button has been pressed or the timeout has occurred
  if (buttonPressed || testTimedOut) {
    // End the Unity test framework
    UNITY_END();
  }
}