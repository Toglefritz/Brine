import 'response.dart';
import 'response_type.dart';

/// A class representing a response containing the device ID.
class DeviceIdResponse extends Response {
  /// Creates an instance of [DeviceIdResponse] with the provided [deviceId].
  ///
  /// The [deviceId] parameter specifies the device ID returned by the Brine device.
  DeviceIdResponse(this.deviceId) : super(responseType: ResponseType.deviceId);

  /// Factory constructor to create a [DeviceIdResponse] object from a JSON map.
  ///
  /// The [json] parameter is a map representing the JSON response received from the Brine device.
  factory DeviceIdResponse.fromJson(Map<String, dynamic> json) {
    return DeviceIdResponse(json['device_id'] as String);
  }

  /// The device ID returned in the response.
  final String deviceId;

  /// Converts the response to a JSON-serializable map.
  ///
  /// This method provides the specific JSON structure for the device ID response.
  @override
  Map<String, dynamic> toJson() {
    return {
      'response': responseType,
      'device_id': deviceId,
    };
  }
}
