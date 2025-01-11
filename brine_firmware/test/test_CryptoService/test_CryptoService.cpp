#include <CryptoService.h>
#include <Wire.h>
#include <unity.h>

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

// Create an instance of the CryptoService class
CryptoService cryptoService;

/**
 * @brief Test for initializing the CryptoService class.
 *
 * This function tests the `begin` function of the CryptoService class. It
 * verifies if the CryptoService class is initialized successfully.
 */
void test_crypto_service_begin(void) {
  // Initialize the CryptoService
  bool beginResult = cryptoService.begin(cryptoI2C);

  TEST_ASSERT_TRUE_MESSAGE(beginResult, "Failed to initialize CryptoService");
}

/**
 * @brief Test for reading the public key from the ATECC508A device.
 *
 * This function tests the `readPublicKey` function of the CryptoService class.
 * It verifies if the public key is read successfully from the ATECC508A device.
 */
void test_crypto_service_read_public_key(void) {
  // Read the public key
  String publicKey = cryptoService.readPublicKey();

  TEST_ASSERT_NOT_NULL_MESSAGE(publicKey, "Public key is null");
}

/**
 * @brief Test for signing data using the private key stored on the ATECC508A
 * device.
 *
 * This function tests the `signRequest` function of the CryptoService class.
 * It verifies if the data is signed successfully using the private key stored
 * on the ATECC508A device.
 */
void test_crypto_service_sign_request(void) {
  // Sign the request
  String data = "{\"device_id\":\"vast_teal_elephant\",\"battery_level\":50,\"salt_distance\":1505}";
  String signature;

  bool signResult = cryptoService.signRequest(data, signature);

  TEST_ASSERT_TRUE_MESSAGE(signResult, "Failed to sign the request");
  TEST_ASSERT_NOT_NULL_MESSAGE(signature, "Signature is null");
}

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