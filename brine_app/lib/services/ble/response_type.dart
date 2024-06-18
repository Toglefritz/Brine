/// An enumeration of response types that are supported by the Brine BLE API.
enum ResponseType {
  /// A response containing the device ID.
  deviceId,

  /// A response containing a list of WiFi networks discovered by the Brine device.
  networks,

  /// An error response.
  error;

  /// A getter for the key corresponding to a response for the command in the JSON representation of the response. This
  /// key determines the type of response.
  String get responseKey {
    switch (this) {
      case ResponseType.deviceId:
        return 'device_id';
      case ResponseType.networks:
        return 'networks';
      case ResponseType.error:
        return 'error';
    }
  }
}
