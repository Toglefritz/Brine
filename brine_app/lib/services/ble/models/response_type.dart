/// An enumeration of response types that are supported by the Brine BLE API.
enum ResponseType {
  /// A response containing the device ID.
  deviceId,

  /// A response indicating that the PSK was successfully transferred to the Brine device and saved to NVS.
  pskTransferred,

  /// A response containing a list of WiFi networks discovered by the Brine device.
  networks,

  /// A response indicating that the Brine device successfully connected to a WiFi network.
  wifiConnected,

  /// A response indicating that the Brine device encountered a failure while attempting to connect to a WiFi network.
  wifiConnectError,

  /// A response indicating that the Brine device has successfully concluded the provisioning process.
  provisioningComplete,

  /// An error response.
  error;

  /// A getter for the key corresponding to a response for the command in the JSON representation of the response. This
  /// key determines the type of response.
  String get responseKey {
    switch (this) {
      case ResponseType.deviceId:
        return 'device_id';
      case ResponseType.pskTransferred:
        return 'psk_saved';
      case ResponseType.networks:
        return 'networks';
      case ResponseType.wifiConnected:
        return 'wifi_connected';
      case ResponseType.wifiConnectError:
        return 'wifi_connect_error';
      case ResponseType.provisioningComplete:
        return 'provisioning_complete';
      case ResponseType.error:
        return 'error';
    }
  }
}
