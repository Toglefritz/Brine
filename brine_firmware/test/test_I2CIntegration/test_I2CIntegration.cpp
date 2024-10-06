#include <I2CLED.h>
#include <Wire.h>
#include <unity.h>
#include <I2CButton.h>
#include <DistanceSensor.h>
#include "BLEModule.h"
#include <CryptoService.h>

/*
 *  This test file tests the all I2C peripherals together in a single test.
 *  The purpose of this test is to verify that all I2C peripherals can be
 *  initialized and used together without conflicts.
 *
 *  Run this test with the command `pio test --filter test_I2CIntegration`.
 */

// A DistanceSensor instance used for this test.
DistanceSensor distanceSensor;

// A BLEModule instance used for this test.
BLEModule bleModule;

// A CryptoService instance used for this test.
CryptoService cryptoService;

/**
 * @brief The button handler function.
 *
 * This function is called when the button is pressed. It sets the
 * `buttonPressed` variable to true, indicating that the button was pressed.
 */
void buttonHandler() {
    // End the test with a success message.
    TEST_PASS();
}

/**
 * @brief Test that all I2C peripherals can be initialized.
 */
void test_initialize_i2c_peripherals(void) {
    // Initialize the LED.
    bool ledInitialized = I2CLED::getInstance().begin();

    // Initialize the button.
    bool buttonInitialized = I2CButton::getInstance().begin(buttonHandler);

    // Initialize the distance sensor.
    bool distanceSensorInitialized = distanceSensor.begin();

    // Initialize the BLE module.
    bool bleModuleInitialized = bleModule.begin();

    // Initialize the CryptoService.
    bool cryptoServiceInitialized = cryptoService.begin();

    // Test that all peripherals were initialized successfully.
    TEST_ASSERT_TRUE(ledInitialized && buttonInitialized && distanceSensorInitialized && bleModuleInitialized && cryptoServiceInitialized);
}

/*
* @brief Test the LED.
*/
void test_led(void) {
    // Turn the LED on.
    bool ledOn = I2CLED::getInstance().turnOn();

    bool ledOff = I2CLED::getInstance().turnOff();

    // Test that the LED was turned on successfully.
    TEST_ASSERT_TRUE(ledOn && ledOff);
}

/**
 * @brief Test the startMeasurement function of the DistanceSensor class.
 *
 * This test verifies that the sensor starts the measurement correctly and
 * obtains a valid range status.
 */
void test_start_measurement(void) {
    // Test that the sensor starts measurement correctly
    distanceSensor.startMeasurement();
    // Check that the sensor obtained a valid measurement
    TEST_ASSERT(distanceSensor.getRangeStatus() == 0);
}

/**
 * @brief Test case for the get_distance function.
 *
 * This test verifies that the distance sensor is able to correctly measure the
 * distance. It starts the measurement, gets the distance, and checks that the
 * distance is non-negative.
 */
void test_get_distance(void) {
    // Test that the sensor gets distance correctly
    // Start measurement before getting distance
    distanceSensor.startMeasurement();
    int distance = distanceSensor.getDistance();
    // Assuming that the sensor returns a non-negative distance
    TEST_ASSERT_GREATER_OR_EQUAL(0, distance);
}

/**
 * @brief Test for initializing the CryptoService class.
 *
 * This function tests the `begin` function of the CryptoService class. It
 * verifies if the CryptoService class is initialized successfully.
 */
void test_crypto_service_begin(void) {
  // Initialize the CryptoService
  bool beginResult = cryptoService.begin();

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
 * @brief Initializes the test environment and runs the Unity test framework.
 *
 * This function is called once at the beginning of the test program. It allows
 * some time for the serial port to initialize, starts the Unity test framework,
 * and runs the test function "test_function_testLedControl". Finally, it ends
 * the Unity test framework.
 */
void setup() {
    // Join the I2C bus
    Wire.begin();

    // Start the Unity test framework
    UNITY_BEGIN();

    RUN_TEST(test_initialize_i2c_peripherals);
    RUN_TEST(test_led);
    RUN_TEST(test_start_measurement);
    RUN_TEST(test_get_distance);
    RUN_TEST(test_crypto_service_begin);
    RUN_TEST(test_crypto_service_read_public_key);
    RUN_TEST(test_crypto_service_sign_request);

    // End the Unity test framework
    UNITY_END();
}

void loop() {
    // Do nothing
}