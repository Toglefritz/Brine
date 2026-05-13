import 'package:brine/services/device_management/models/brine_device.dart';
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
      /// JSON map. In this test, the salt distance, appliance height, and battery level are all doubles.
      test('should successfully create a BrineDevice object from a JSON map', () {
        // Set up the JSON map matching the current BrineDevice.fromJson schema.
        final Map<String, dynamic> json = {
          'device_id': 'shadowy_scarlet_owl',
          'name': '7b67',
          'salt_distance': 210.0,
          'appliance_height': 300.0,
          'battery_level': 0.9,
          'last_updated': '2025-05-10T12:00:00.000Z',
        };

        // Create a BrineDevice object from the JSON map.
        final BrineDevice brineDevice = BrineDevice.fromJson(json);

        // Verify that the BrineDevice object was created successfully.
        expect(brineDevice.deviceId, 'shadowy_scarlet_owl');
        expect(brineDevice.name, '7b67');
        expect(brineDevice.saltDistance, 210.0);
        expect(brineDevice.applianceHeight, 300.0);
        expect(brineDevice.saltLevel, 0.7); // 210 / 300 = 0.7
        expect(brineDevice.batteryLevel, 0.9);
      });

      /// This test verifies that the `fromJson` factory constructor successfully creates a [BrineDevice] object from a
      /// JSON map. In this test, the salt distance, appliance height, and battery level are integers (which the factory
      /// should handle by converting to doubles).
      test('should successfully create a BrineDevice object from a JSON map with integer salt and battery levels', () {
        // Set up the JSON map with integer values.
        final Map<String, dynamic> json = {
          'device_id': 'swift_onyx_hawk',
          'name': '3c18',
          'salt_distance': 0,
          'appliance_height': 500,
          'battery_level': 1,
          'last_updated': '2025-04-28T08:00:00.000Z',
        };

        // Create a BrineDevice object from the JSON map.
        final BrineDevice brineDevice = BrineDevice.fromJson(json);

        // Verify that the BrineDevice object was created successfully.
        expect(brineDevice.deviceId, 'swift_onyx_hawk');
        expect(brineDevice.name, '3c18');
        expect(brineDevice.saltDistance, 0.0);
        expect(brineDevice.applianceHeight, 500.0);
        expect(brineDevice.saltLevel, 0.0); // 0 / 500 = 0.0
        expect(brineDevice.batteryLevel, 1.0);
      });
    });
  });
}
