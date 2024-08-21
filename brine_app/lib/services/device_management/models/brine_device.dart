/// Represents a Brine monitor device and includes the salt and battery levels obtained from the device, along with a
/// timestamp of when the levels were last retrieved.
class BrineDevice {
  /// A unique identifier for the device.
  final String deviceId;

  /// The name of the Brine BLE device, which is based on the device's Bluetooth MAC address.
  final String name;

  /// The percentage of the maximum salt fill level remaining in the water softener.
  final double saltLevel;

  /// The percentage of battery life remaining on the Brine monitor.
  final double batteryLevel;

  /// The timestamp when the levels were last retrieved.
  final DateTime retrievalTimestamp;

  /// Creates an instance of [BrineDevice].
  BrineDevice({
    required this.deviceId,
    required this.name,
    required this.saltLevel,
    required this.batteryLevel,
    required this.retrievalTimestamp,
  });

  /// Creates an instance of [BrineDevice] from a JSON object.
  factory BrineDevice.fromJson(Map<String, dynamic> json) {
    // Get the salt level. The salt level can be an integer or a double, so it is necessary to check the type.
    final double saltLevel =
    json['salt_level'] is int ? (json['salt_level'] as int).toDouble() : json['salt_level'] as double;

    // Get the battery level. The battery level can be an integer or a double, so it is necessary to check the type.
    final double batteryLevel =
    json['battery_level'] is int ? (json['battery_level'] as int).toDouble() : json['battery_level'] as double;

    return BrineDevice(
      deviceId: json['device_id'] as String,
      name: json['name'] as String,
      saltLevel: saltLevel,
      batteryLevel: batteryLevel,
      retrievalTimestamp: DateTime.now(),
    );
  }
}
