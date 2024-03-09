/// Represents a Brine monitor device and includes the salt and battery levels obtained from the device, along with a
/// timestamp of when the levels were last retrieved.
class BrineDevice {
  /// A unique identifier for the device.
  final String deviceId;

  /// The percentage of the maximum salt fill level remaining in the water
  /// softener.
  final double saltLevel;

  /// The percentage of battery life remaining on the Brine monitor.
  final double batteryLevel;

  /// The timestamp when the levels were last retrieved.
  final DateTime retrievalTimestamp;

  BrineDevice({
    required this.deviceId,
    required this.saltLevel,
    required this.batteryLevel,
    required this.retrievalTimestamp,
  });
}
