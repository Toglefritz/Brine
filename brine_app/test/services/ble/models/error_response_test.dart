import 'package:brine/services/ble/models/error_response.dart';
import 'package:flutter_test/flutter_test.dart';

/// This file contains tests for the [ErrorResponse] class.
///
/// This test can be run using the following command:
///
/// ```sh
/// flutter test test/services/ble/models/error_response_test.dart
/// ```
void main() {
  /// This group contains tests for the `ErrorResponse` class.
  group('ErrorResponse', () {
    /// This group contains tests for the `toJson` method.
    group('toJson', () {
      /// This test verifies that the `toJson` method successfully converts an [ErrorResponse] object to a
      /// JSON-serializable map.
      test('should successfully convert an ErrorResponse object to a JSON-serializable map', () {
        // Create an ErrorResponse object with an error message.
        final ErrorResponse response = ErrorResponse('mock_error_message');

        // Convert the ErrorResponse object to a JSON-serializable map.
        final Map<String, dynamic> json = response.toJson();

        // Verify that the ErrorResponse object was successfully converted to a JSON-serializable map.
        expect(json, {
          'response': response.responseType,
          'message': 'mock_error_message',
        });
      });
    });
  });
}
