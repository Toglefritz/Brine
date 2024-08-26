#include "CryptoService.h"

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
  // Initialize I2C communication
  Wire.begin();

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
byte *CryptoService::readPublicKey() {
  byte *publicKey = atecc.publicKey64Bytes;

  return publicKey;
}