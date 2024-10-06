#include "CryptoService.h"
#include <base64.h>
#include <mbedtls/sha256.h>

/**
 * @brief Initialize the CryptoService module.
 */
CryptoService::CryptoService() {}

/**
 * @brief Initialize the ATECC508A module.
 *
 * @return True if initialization is successful, otherwise false.
 */
bool CryptoService::begin() {
  if (!atecc.begin()) {
    debugService.debugPrintln("Failed to initialize ATECC508A!");
    return false;
  }

  debugService.debugPrintln("ATECC508A initialized successfully.");
  return true;
}

/**
 * @brief Obtains the public key from the ATECC508A device.
 *
 * This method retrieves the public key from the ATECC508A device. This
 * public key is shared with the cloud backend to verify the signature of
 * the data sent by the device.
 *
 * @param[out] publicKey The public key obtained from the device.
 */
String CryptoService::readPublicKey() {
  byte *publicKey = atecc.publicKey64Bytes;

  // Convert the binary public key to a base64 encoded string
  String encodedPublicKey = base64::encode(publicKey, 64);

  return encodedPublicKey;
}

/**
 * @brief Signs the given data using the private key stored on the ATECC508A
 * device.
 *
 * This method signs the given data using the private key stored on the
 * ATECC508A device. The signature is returned as a base64 encoded string. This
 * function is used to sign requests before they are sent to the cloud backend.
 * The cloud backend system can then verify the signature using the public key,
 * which it obtains from the mobile app after the Brine monitor sends this key
 * to the mobile app during the provisioning process.
 *
 * @param data The data to sign.
 * @param signature The signature of the data.
 */
bool CryptoService::signRequest(const String &data, String &signature) {
  debugService.debugPrintln("Signing request...");

  // Step 1: Hash the input data using SHA-256 into a 32-byte hash
  byte hash[32];
  mbedtls_sha256_context sha_ctx;
  mbedtls_sha256_init(&sha_ctx);
  mbedtls_sha256_starts(&sha_ctx, 0); // 0 for SHA-256
  mbedtls_sha256_update(&sha_ctx, (const unsigned char *)data.c_str(), data.length());
  mbedtls_sha256_finish(&sha_ctx, hash);
  mbedtls_sha256_free(&sha_ctx);

  // Step 2: Use the ATECC508A to sign the hash
  if (!atecc.createSignature(hash)) {
    debugService.debugPrintln("Failed to sign the hash with ATECC508A.");
    return false;
  }

  // Step 3: Encode the raw signature in Base64 for transmission
  byte *signatureBytes = atecc.signature;
  signature = base64::encode(signatureBytes, 64);

  debugService.debugPrintln("Request signed successfully.");

  return true;
}
