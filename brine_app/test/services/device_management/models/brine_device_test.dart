import 'package:brine/models/brine_device.dart';
import 'package:flutter_test/flutter_test.dart';

/// This file contains tests for the [BrineDevice] class.
///
/// This test can be run using the following command:
///
/// ```sh
/// flutter test test/services/device_management/models/brine_device_test.dart
/// ```
void main() {
  /// This group contains tests for the `BrineDevice` class.
  group('BrineDevice', () {
    /// This group contains tests for the `fromJson` factory constructor.
    group('fromJson', () {
      /// This test verifies that the `fromJson` factory constructor successfully creates a [BrineDevice] object from a
      /// JSON map. In this test, the salt and battery levels are both decimals.
      test('should successfully create a BrineDevice object from a JSON map',
          () {
        // Set up the JSON map.
        final Map<String, dynamic> json = {
          'device_id': 'shadowy_scarlet_owl',
          'name': '7b67',
          'salt_level': 0.7,
          'battery_level': 0.9,
        };

        // Create a BrineDevice object from the JSON map.
        final BrineDevice brineDevice = BrineDevice.fromJson(json);

        // Verify that the BrineDevice object was created successfully.
        expect(brineDevice.deviceId, 'shadowy_scarlet_owl');
        expect(brineDevice.name, '7b67');
        expect(brineDevice.saltLevel, 0.7);
        expect(brineDevice.batteryLevel, 0.9);
      });

      /// This test verifies that the `fromJson` factory constructor successfully creates a [BrineDevice] object from a
      /// JSON map. In this test, the salt and battery levels are both integers.
      test(
          'should successfully create a BrineDevice object from a JSON map with integer salt and battery levels',
          () {
        // Set up the JSON map.
        final Map<String, dynamic> json = {
          'device_id': 'swift_onyx_hawk',
          'name': '3c18',
          'salt_level': 0,
          'battery_level': 1,
        };

        // Create a BrineDevice object from the JSON map.
        final BrineDevice brineDevice = BrineDevice.fromJson(json);

        // Verify that the BrineDevice object was created successfully.
        expect(brineDevice.deviceId, 'swift_onyx_hawk');
        expect(brineDevice.name, '3c18');
        expect(brineDevice.saltLevel, 0.0);
        expect(brineDevice.batteryLevel, 1.0);
      });
    });
  });
}
