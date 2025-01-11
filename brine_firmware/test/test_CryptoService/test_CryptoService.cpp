#include <Wire.h>
#include <unity.h>
#include "test_CryptoService.h"

/*
 * Test file for the CryptoService class. This test file tests the
 * functionality of the cryptographic services on the ESP32 by verifying that it
 * initializes correctly and is able to read the public key and sign data.
 *
 *  Run this test with the command `pio test --filter test_CryptoService`.
 */

// Define pins for the main I2C bus
#define CRYPTO_SDA_PIN 19
#define CRYPTO_SCL_PIN 18

// The I2C interface for this test.
TwoWire cryptoI2C = TwoWire(0);

/**
 * @brief Test for initializing the CryptoService class.
 *
 * This function tests the `begin` function of the CryptoService class. It
 * verifies if the CryptoService class is initialized successfully.
 */
void test_crypto_service_begin(void) { test_crypto_service_begin(cryptoI2C); }

/**
 * @brief Initializes the test suite and runs the test cases.
 *
 * This function is called once at the beginning of the test suite. It
 * initializes the Unity test framework and runs the test cases defined in the
 * suite.
 */
void setup() {
  // Initialize the custom I2C instance with specified SDA and SCL pins
  cryptoI2C.begin(CRYPTO_SDA_PIN, CRYPTO_SCL_PIN);

  UNITY_BEGIN();

  RUN_TEST(test_crypto_service_begin);
  RUN_TEST(test_crypto_service_read_public_key);
  RUN_TEST(test_crypto_service_sign_request);

  UNITY_END();
}

void loop() {
  // Do nothing
}