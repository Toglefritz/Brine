#ifndef CRYPTO_SERVICE_H
#define CRYPTO_SERVICE_H

#include <SparkFun_ATECCX08a_Arduino_Library.h>
#include <Wire.h>

#include "../../include/DebugService.h"

/**
 * @class CryptoService
 * @brief A class to provide cryptographic services using the ATECC508A device.
 *
 * The Brine monitor is equipped with a crytographic coprocessor (ATECC508A)
 * that can be used to sign data. This infrastructure is used to sign payloads
 * sent to the cloud to ensure the integrity and authenticity of the data.
 *
 * The CryptoService class provides an interface to the ATECC508A device to
 * sign data using the private key stored on the device. The cloud backend
 * can then verify the signature using the corresponding public key.
 */
class CryptoService {
public:
  /**
   * @brief Constructor to initialize the CryptoService module.
   */
  CryptoService();

  /**
   * @brief Initialize the ATECC508A module.
   *
   * @return True if initialization is successful, otherwise false.
   */
  bool begin();

  /**
   * @brief Obtains the public key from the ATECC508A device.
   *
   * This method retrieves the public key from the ATECC508A device. This
   * public key is shared with the cloud backend to verify the signature of
   * the data sent by the device.
   * 
   * The ATECC508A device returns the public key in binary format. Therefore,
   * this method converts the binary public key to a base64 encoded string
   * before returning it.
   *
   * @param[out] publicKey The public key obtained from the device.
   */
  String readPublicKey();

  // TODO(Toglefritz): Implement signing function

private:
  /**
   * @brief A reference to the ATECC508A device.
   */
  ATECCX08A atecc;

  /**
   * @brief A reference to the DebugService singleton.
   *
   * This is used for debugging purposes.
   */
  DebugService &debugService = DebugService::getInstance();
};

#endif // CRYPTO_SERVICE_H