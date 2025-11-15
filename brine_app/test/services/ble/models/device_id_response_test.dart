import 'package:brine/services/ble/models/device_id_response.dart';
import 'package:flutter_test/flutter_test.dart';

/// This file contains tests for the [DeviceIdResponse] class.
///
/// This test can be run using the following command:
///
/// ```sh
/// flutter test test/services/ble/models/device_id_response_test.dart
/// ```
void main() {
  /// This group contains tests for the `DeviceIdResponse` class.
  group('DeviceIdResponse', () {
    /// This group contains tests for the `toJson` method.
    group('toJson', () {
      /// This test verifies that the `toJson` method successfully converts a [DeviceIdResponse] object to a
      /// JSON-serializable map.
      test('should successfully convert a DeviceIdResponse object to a JSON-serializable map', () {
        // Create a DeviceIdResponse object with a device ID.
        final DeviceIdResponse response = DeviceIdResponse('mock_device_id');

        // Convert the DeviceIdResponse object to a JSON-serializable map.
        final Map<String, dynamic> json = response.toJson();

        // Verify that the DeviceIdResponse object was successfully converted to a JSON-serializable map.
        expect(json, {
          'response': response.responseType,
          'device_id': 'mock_device_id',
        });
      });
    });
  });
}
