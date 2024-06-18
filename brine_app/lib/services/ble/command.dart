import 'dart:convert';

import 'command_type.dart';

/// Represents a command sent to the Brine BLE device.
///
/// The [Command] class is the base class for all commands that can be sent to the Brine device. Each command is
/// represented by a specific [CommandType] and can be serialized to a JSON format to be communicated over Bluetooth
/// Low Energy (BLE).
///
/// The [CommandType] enum defines the types of commands that can be issued. Each command type corresponds to a
/// specific operation that the Brine device can perform, such as retrieving the device ID or other functionalities to
/// be implemented.
class Command {
  /// Creates an instance of [Command] with the provided [CommandType]
  Command({
    required this.commandType,
  });

  /// The type of command. Each [CommandType] value corresponds to an individual command to be converted to JSON format
  /// and sent to the Brine device over a BLE connection.
  final CommandType commandType;

  /// Converts the command to a JSON-serializable map.
  Map<String, dynamic> _toJson() {
    final Map<String, dynamic> json = {
      'command': commandType.value,
    };

    return json;
  }

  /// Converts the command to a serialized JSON string.
  String toJsonString() {
    // Convert the command to JSON.
    final Map<String, dynamic> json = _toJson();

    // Serialize the JSON into a string.
    final String serializedJson = jsonEncode(json);

    return serializedJson;
  }
}
