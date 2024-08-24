import 'package:brine/services/ble/models/command.dart';
import 'package:brine/services/ble/models/command_type.dart';
import 'package:flutter_test/flutter_test.dart';

/// This file contains tests for the [Command] class.
///
/// This test can be run using the following command:
///
/// ```sh
/// flutter test test/services/ble/models/command_test.dart
/// ```
void main() {
  /// This group contains tests for the `Command` class.
  group('Command', () {
    /// This group contains tests for the `toJsonString` method.
    group('toJsonString', () {
      /// This test verifies that the `toJsonString` method successfully converts a [Command] object to a serialized
      /// JSON string.
      test('should successfully convert a Command object to a serialized JSON string for the `scan` command type', () {
        // Create a Command object with the CommandType.retrieveDeviceId type.
        final Command command = Command(commandType: CommandType.scan);

        // Convert the Command object to a serialized JSON string.
        final String jsonString = command.toJsonString();

        // Verify that the Command object was successfully converted to a serialized JSON string.
        expect(jsonString, '{"command":"scan","parameters":"{}"}');
      });

      /// This test verifies that the `toJsonString` method successfully converts a [Command] object to a serialized
      /// JSON string. The `wifiConnect` command type is used in this test.
      test(
          'should successfully convert a Command object to a serialized JSON string for the `getDeviceId` command type',
          () {
        // Create a Command object with the CommandType.retrieveDeviceId type.
        final Command command = Command(commandType: CommandType.wifiConnect);

        // Create parameters for the command.
        final Map<String, dynamic> parameters = {
          'ssid': 'mock_ssid',
          'password': 'mock_password',
        };

        // Convert the Command object to a serialized JSON string.
        final String jsonString = command.toJsonString(parameters: parameters);

        // Verify that the Command object was successfully converted to a serialized JSON string.
        expect(jsonString, '{"command":"wifi_connect","parameters":{"ssid":"mock_ssid","password":"mock_password"}}');
      });
    });
  });
}
