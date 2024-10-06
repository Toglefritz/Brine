/// An enumeration of command types that are supported by the Brine BLE API.
enum CommandType {
  /// Requests that the Brine provide its device ID. The device ID of a Brine device has the form,
  /// <adjective>_<adjective>_<noun>, for example, "vast_teal_elephant."
  getDeviceId(value: 'get_device_id', responseKey: 'device_id'),

  /// Requests that the Brine device provide the public key held by its cryptographic coprocessor.
  getPublicKey(value: 'get_public_key', responseKey: 'public_key'),

  /// Instructs the Brine device to scan for WiFi networks and send the SSID and RSSI of each network to the app.
  scan(value: 'scan', responseKey: 'networks'),

  /// Provides the SSID and password of a WiFi network to which the Brine device should connect.
  wifiConnect(value: 'wifi_connect', responseKey: 'wifi_connection_status'),

  /// Requests that the Brine device conclude the provisioning process and return to normal operation.
  completeProvisioning(value: 'complete_provisioning', responseKey: 'provisioning_complete');

  /// Creates an instance of [CommandType].
  const CommandType({
    required this.value,
    required this.responseKey,
  });

  /// The value for the command in its JSON representation.
  ///
  /// Bluetooth API commands consist of a JSON object that contains the key, "command." The value for that key is the
  /// [value] of each [CommandType].
  final String value;

  /// The key corresponding to a response for the command in the JSON representation of the response.
  final String responseKey;
}
