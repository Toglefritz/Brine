/// An enumeration of command types that are supported by the Brine BLE API.
enum CommandType {
  /// Requests that the Brine provide its device ID. The device ID of a Brine device has the form,
  /// <adjective>_<adjective>_<noun>, for example, "vast_teal_elephant."
  getDeviceId('get_device_id');


  /// Creates an instance of [CommandType].
  const CommandType(this.value);

  /// The value for the command in its JSON representation.
  ///
  /// Bluetooth API commands consist of a JSON object that contains the key, "command." The value for that key is the
  /// [value] of each [CommandType].
  final String value;
}
