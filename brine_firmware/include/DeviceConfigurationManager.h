#ifndef DeviceConfigurationManager_h
#define DeviceConfigurationManager_h

/**
 * @class DeviceConfigurationManager
 * @brief Manages device configuration operations via Bluetooth.
 *
 * This class is designed to facilitate the interaction between an IoT device and an external client device,
 * allowing the external client to set various parameters and configuration options on the IoT device using
 * Bluetooth communication. It encapsulates the necessary methods to receive, process, and apply configuration
 * changes transmitted from the client device.
 *
 * The class provides a high-level interface for initiating the Bluetooth communication, handling incoming
 * configuration data, validating the data against predefined criteria, and updating the IoT device's settings
 * accordingly. It ensures that the configuration process is secure, efficient, and error-resistant, providing
 * feedback to the client device about the status of the configuration operations.
 *
 * Usage example:
 * @code
 * DeviceConfigurationManager configManager;
 * configManager.initializeBluetooth();
 * configManager.listenForConfigurationChanges();
 * @endcode
 *
 * @note The class requires a Bluetooth module to be initialized and configured separately before its methods
 * can be effectively used. It is also responsible for managing the lifecycle of the Bluetooth connection during
 * the configuration process.
 *
 * @see BluetoothManager for details on managing Bluetooth connectivity.
 */
class DeviceConfigurationManager {
public:
  /**
   * @brief Get the Instance object
   *
   * @return ProvisioningManager&
   */
  static DeviceConfigurationManager &getInstance() {
    static DeviceConfigurationManager instance;

    return instance;
  }

  /**
   * @brief Starts the provisioning process.
   *
   * This function is called when the button is pressed to initiate the provisioning process. It wakes up the ESP32
   * from deep sleep and initializes the Bluetooth system.
   */
  void startProvisioning() {
    DebugService::getInstance().debugPrintln("Button pressed. Starting provisioning process.");

    // TODO(Toglefritz): Wake up the ESP32 from deep sleep.

    // Initialize the Bluetooth system.
    initializeBluetooth();
  }

  /**
   * Stops the provisioning process by ending the BLE module.
   */
  void stopProvisioning() {
    // TODO(Toglefritz): Send salt and battery levels to Firebase.

    // End the BLE module
    bleModule.end();
  }

  /**
   * @brief Sets the callback function for handling BLE connection events.
   *
   * @param callback The callback function to be set.
   */
  void setExternalConnectionCallback(BLEConnectionCallback callback) { externalConnectionCallback = callback; }

  /**
   * @brief Sets the callback function for handling BLE disconnection events.
   *
   * @param callback The callback function to be set.
   */
  void setExternalDisconnectionCallback(BLEDisconnectionCallback callback) { externalDisconnectionCallback = callback; }

  /**
   * @brief Sets the callback function for handling BLE write events.
   *
   * @param callback The callback function to be set.
   */
  void setExternalWriteCallback(BLEWriteCallback callback) { externalWriteCallback = callback; }

  /**
   * @brief Sets the callback function for handling BLE read events.
   *
   * @param callback The callback function to be set.
   */
  void setExternalReadCallback(BLEReadCallback callback) { externalReadCallback = callback; }

  /**
   * @brief Sets the callback function for handling BLE descriptor write
   * events.
   *
   * @param callback The callback function to be set.
   */
  void setExternalDescriptorWriteCallback(BLEDescriptorWriteCallback callback) {
    externalDescriptorWriteCallback = callback;
  }

  /**
   * @brief Sets the value of a Bluetooth Low Energy (BLE) characteristic.
   *
   * This method is designed to write a potentially long value to a BLE characteristic by dividing it into smaller
   * chunks. BLE characteristics have a maximum length limit for their values, which can vary depending on the BLE stack
   * and the underlying hardware capabilities. This limit is often in the range of 20 to 512 bytes. Writing values that
   * exceed this limit in a single operation is not possible; hence, the need to divide long values into manageable
   * chunks.
   *
   * The division of long values into smaller chunks ensures compatibility across different BLE devices and platforms,
   * enhancing the reliability of data transmission over BLE. It allows for the efficient use of BLE's limited bandwidth
   * and ensures that large data payloads can be transmitted successfully without exceeding the maximum transmission
   * unit (MTU) size limitations.
   *
   * The method uses a special character, 0x0A (newline character in ASCII), to denote the end of the last chunk. This
   * character acts as a delimiter, signaling the receiving end that it has received the complete value and that there
   * are no more chunks to expect. This is crucial for the receiving device to know when the entire value has been
   * successfully transmitted and can be processed as a whole. The use of a delimiter is a common practice in
   * communication protocols to mark the end of a message or data segment, ensuring data integrity and facilitating the
   * correct parsing and handling of received data.
   *
   * @param value The long value to be written to the BLE characteristic, divided into smaller chunks if necessary.
   * @note It is important to ensure that the receiving end of the BLE communication is implemented to handle the
   * chunked data transmission and the use of the 0x0A character as the end-of-data delimiter.
   */
  void setCharacteristicValue(BLECharacteristic *pCharacteristic, const std::string &value) {
    // The maximum chunk size for BLE characteristic values.
    size_t chunkSize = 512;

    // The total length of the value to be transmitted.
    size_t totalLength = value.length();

    // The current offset in the value string.
    size_t offset = 0;

    // Divide the value into chunks and send them sequentially.
    while (offset < totalLength) {
      // Determine the length of the current chunk.
      size_t length = std::min(chunkSize, totalLength - offset);

      // Check if this is the last chunk.
      bool isLastChunk = (offset + length) >= totalLength;

      // Extract the current chunk from the value string.
      std::string chunk = value.substr(offset, length);

      // Append termination byte to the last chunk
      if (isLastChunk) {
        chunk += '\x0A'; // Append termination byte
      }

      // Use the parent class's setValue to actually set the chunk value
      pCharacteristic->setValue(chunk);

      // Notify subscribed clients
      pCharacteristic->notify();

      offset += length;
    }
  }

private:
  // Instance of BLEModule
  BLEModule bleModule;

  /**
   * @brief External callback for handling BLE connection events.
   */
  BLEConnectionCallback externalConnectionCallback;

  /**
   * @brief External callback for handling BLE disconnection events.
   */
  BLEDisconnectionCallback externalDisconnectionCallback;

  /**
   * @brief External callback for handling BLE characteristic write events.
   */
  BLEWriteCallback externalWriteCallback;

  /**
   * @brief External callback for handling BLE characteristic read events.
   */
  BLEReadCallback externalReadCallback;

  /**
   * @brief External callback for handling BLE descriptor write events.
   */
  BLEDescriptorWriteCallback externalDescriptorWriteCallback;

  /**
   * @brief Private constructor to enforce singleton pattern.
   */
  DeviceConfigurationManager() {
    // Register BLE callbacks
    bleModule.setConnectionCallback([this](BLEServer *pServer) {
      DebugService::getInstance().debugPrintln("Device connected");
      if (externalConnectionCallback)
        externalConnectionCallback(pServer);
    });

    bleModule.setDisconnectionCallback([this](BLEServer *pServer) {
      DebugService::getInstance().debugPrintln("Device disconnected");
      if (externalDisconnectionCallback)
        externalDisconnectionCallback(pServer);
    });

    bleModule.setWriteCallback([this](BLECharacteristic *pCharacteristic) {
      std::string value = pCharacteristic->getValue();
      DebugService::getInstance().debugPrintln("Characteristic written: " + String(value.c_str()));
      if (externalWriteCallback)
        externalWriteCallback(pCharacteristic);
    });

    bleModule.setReadCallback([this](BLECharacteristic *pCharacteristic) {
      DebugService::getInstance().debugPrintln("Characteristic read");
      if (externalReadCallback)
        externalReadCallback(pCharacteristic);
    });

    bleModule.setDescriptorWriteCallback([this](BLEDescriptor *pDescriptor) {
      uint8_t *data = pDescriptor->getValue();
      if (data[0] == 0x01) {
        DebugService::getInstance().debugPrintln("Notifications enabled");
      } else if (data[0] == 0x00) {
        DebugService::getInstance().debugPrintln("Notifications disabled");
      }
      if (externalDescriptorWriteCallback)
        externalDescriptorWriteCallback(pDescriptor);
    });
  }

  /**
   * @brief Initializes Bluetooth communication, which is used during the provisioning process.
   */
  void initializeBluetooth() {
    // Initialize the BLEModule
    bool bleBeginSuccess = bleModule.begin();

    if (!bleBeginSuccess) {
      DebugService::getInstance().debugPrintln("Failed to initialize BLE module.");
      return;
    }

    // Begin advertising over BLE
    bool bleAdvertiseSuccess = bleModule.advertise();

    if (!bleAdvertiseSuccess) {
      DebugService::getInstance().debugPrintln("Failed to start advertising.");
      return;
    }

    DebugService::getInstance().debugPrintln("Started advertising over BLE");
  }

  // Prevent copying and assignment
  DeviceConfigurationManager(const DeviceConfigurationManager &) = delete;
  DeviceConfigurationManager &operator=(const DeviceConfigurationManager &) = delete;
};

#endif // DeviceConfigurationManager_h