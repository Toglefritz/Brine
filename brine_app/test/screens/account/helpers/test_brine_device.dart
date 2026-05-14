import 'package:brine/services/device_management/models/brine_device.dart';

/// Creates a [BrineDevice] instance for use in tests.
BrineDevice createTestDevice({
  String deviceId = 'test_device_id',
  String name = 'a1b2',
  double saltDistance = 150,
  double applianceHeight = 300,
  double saltLevel = 0.5,
  double batteryLevel = 0.8,
  DateTime? lastUpdatedTimestamp,
  DateTime? retrievalTimestamp,
}) {
  return BrineDevice(
    deviceId: deviceId,
    name: name,
    saltDistance: saltDistance,
    applianceHeight: applianceHeight,
    saltLevel: saltLevel,
    batteryLevel: batteryLevel,
    lastUpdatedTimestamp: lastUpdatedTimestamp ?? DateTime(2025, 5, 1, 12),
    retrievalTimestamp: retrievalTimestamp ?? DateTime.now(),
  );
}
