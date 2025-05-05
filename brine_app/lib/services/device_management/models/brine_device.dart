import 'dart:math';

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

  /// A timestamp for when the information about the Brine device was last updated in the database.
  final DateTime lastUpdatedTimestamp;

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
    required this.lastUpdatedTimestamp,
    required this.retrievalTimestamp,
  });

  /// Creates an instance of [BrineDevice] from a JSON object.
  factory BrineDevice.fromJson(Map<String, dynamic> json) {
    // Get the salt level. The salt level can be an integer or a double, so it is necessary to check the type.
    final double saltDistance =
        json['salt_distance'] is int ? (json['salt_distance'] as int).toDouble() : json['salt_distance'] as double;

    // Get the total height of the water softener
    final double applianceHeight = json['appliance_height'] is int
        ? (json['appliance_height'] as int).toDouble()
        : json['appliance_height'] as double;

    // Calculate the salt level as a percentage. If an issue occurs resulting in the salt level exceeding 100%, the
    // salt level will be capped at 100%. This is to prevent the salt level from being displayed as greater than 100%.
    // Similarly, if the salt level is calculated to be less than 0%, the salt level will be capped at 0%.
    final double saltLevel = min(1, max(0, saltDistance / applianceHeight));

    // Get the battery level. The battery level can be an integer or a double, so it is necessary to check the type.
    final double batteryLevel =
        json['battery_level'] is int ? (json['battery_level'] as int).toDouble() : json['battery_level'] as double;

    // Get the last updated timestamp
    final DateTime lastUpdatedTimestamp = DateTime.parse(json['last_updated'] as String);

    return BrineDevice(
      deviceId: json['device_id'] as String,
      name: json['name'] as String,
      saltDistance: saltDistance,
      applianceHeight: applianceHeight,
      saltLevel: saltLevel,
      batteryLevel: batteryLevel,
      lastUpdatedTimestamp: lastUpdatedTimestamp,
      retrievalTimestamp: DateTime.now(),
    );
  }

  /// A helper function used to determine if an update from a Brine device is overdue.
  ///
  /// The [lastUpdatedTimestamp] field determine the last date when the Brine device successfully updated its
  /// information in the Firestore database. There are a number of reasons why a Brine device might stop sending updates.
  /// This getter determines if the most recent update was more than three days in the past.
  bool get isUpdateOverdue => DateTime.now().difference(lastUpdatedTimestamp).inDays > 3;

  /// A helper function for getting the last updated timestamp in a human-readable format.
  /// A getter for the last update time of the device, in the form, MM/DD/YYYY.
  String get lastUpdateTime => '${lastUpdatedTimestamp.month}/${lastUpdatedTimestamp.day}/${lastUpdatedTimestamp.year}';
}
