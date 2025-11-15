import 'package:brine/services/ble/models/wifi_connected_response.dart';
import 'package:flutter_test/flutter_test.dart';

/// This file containts tests for hte [WiFiConnectedResponse] class.
///
/// This test can be run using the following command:
///
/// ```sh
/// flutter test test/services/ble/models/wifi_connected_response_test.dart
/// ```
void main() {
  /// This group contains tests for the `WiFiConnectedResponse` class.
  group('WiFiConnectedResponse', () {
    /// This group contains tests for the `toJson` method.
    group('toJson', () {
      /// This test verifies that the `toJson` method successfully converts a [WiFiConnectedResponse] object to a
      /// JSON-serializable map.
      test('should successfully convert a WiFiConnectedResponse object to a JSON-serializable map', () {
        // Create a WiFiConnectedResponse object with an SSID.
        final WiFiConnectedResponse response = WiFiConnectedResponse('mock_ssid');

        // Convert the WiFiConnectedResponse object to a JSON-serializable map.
        final Map<String, dynamic> json = response.toJson();

        // Verify that the WiFiConnectedResponse object was successfully converted to a JSON-serializable map.
        expect(json, {
          'response': response.responseType,
          'ssid': 'mock_ssid',
        });
      });
    });
  });
}
