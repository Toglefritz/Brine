/// Represents a Brine monitor device and includes the salt and battery levels obtained from the device, along with a
/// timestamp of when the levels were last retrieved.
class BrineDevice {
  /// A unique identifier for the device.
  final String deviceId;

  /// The name of the Brine BLE device, which is based on the device's Bluetooth MAC address.
  final String name;

  /// The distance from the top of the salt in the water softener to the top of the water softener, in millimeters.
  /// This distance represents the raw sensor value from the Brine device. This distance is used to calculate the
  /// salt level in the water softener as a percentage, using the total height of the water softener as the
  /// denominator.
  final double saltDistance;

  /// The total height of the water softener, in millimeters. This value is used to calculate the salt level in the
  /// water softener as a percentage.
  final double applianceHeight;

  /// The percentage of the maximum salt fill level remaining in the water softener. This value is calculated from the
  /// [saltDistance] and [applianceHeight] values.
  final double saltLevel;

  /// The percentage of battery life remaining on the Brine monitor.
  final double batteryLevel;

  /// The public key held by the cryptographic coprocessor of the Brine device, in base64-encoded string format.
  final String publicKey;

  /// The timestamp when the levels were last retrieved.
  final DateTime retrievalTimestamp;

  /// Creates an instance of [BrineDevice].
  BrineDevice({
    required this.deviceId,
    required this.name,
    required this.saltDistance,
    required this.applianceHeight,
    required this.saltLevel,
    required this.batteryLevel,
    required this.publicKey,
    required this.retrievalTimestamp,
  });

  /// Creates an instance of [BrineDevice] from a JSON object.
  factory BrineDevice.fromJson(Map<String, dynamic> json) {
    // Get the salt level. The salt level can be an integer or a double, so it is necessary to check the type.
    final double saltDistance = json['salt_distance'] is int
        ? (json['salt_distance'] as int).toDouble()
        : json['salt_distance'] as double;

    // Get the total height of the water softener
    final double applianceHeight = json['appliance_height'] is int
        ? (json['appliance_height'] as int).toDouble()
        : json['appliance_height'] as double;

    // Calculate the salt level as a percentage
    final double saltLevel = saltDistance / applianceHeight;

    // Get the battery level. The battery level can be an integer or a double, so it is necessary to check the type.
    final double batteryLevel = json['battery_level'] is int
        ? (json['battery_level'] as int).toDouble()
        : json['battery_level'] as double;

    return BrineDevice(
      deviceId: json['device_id'] as String,
      name: json['name'] as String,
      saltDistance: saltDistance,
      applianceHeight: applianceHeight,
      saltLevel: saltLevel,
      batteryLevel: batteryLevel,
      publicKey: json['public_key'] as String,
      retrievalTimestamp: DateTime.now(),
    );
  }
}
