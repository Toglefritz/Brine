import 'package:brine/services/device_management/models/brine_device.dart';

/// Creates a list of [BrineDevice] instances for use in softener monitor tests.
///
/// Each device has a unique ID and name, with default salt and battery levels that represent a healthy device with a
/// recent update (so the overdue view is not triggered).
List<BrineDevice> createTestDevices({int count = 1}) {
  return List.generate(
    count,
    (int index) => BrineDevice(
      deviceId: 'test_device_$index',
      name: 'dev$index',
      saltDistance: 150,
      applianceHeight: 300,
      saltLevel: 0.5,
      batteryLevel: 0.8,
      lastUpdatedTimestamp: DateTime.now().subtract(const Duration(hours: 1)),
      retrievalTimestamp: DateTime.now(),
    ),
  );
}
