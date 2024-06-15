import 'device_response.dart';
import 'error_response.dart';
import 'response_type.dart';

/// An abstract class representing a response from the Brine device.
///
/// The [Response] class is the base class for all response types that can be received from the Brine device over a
/// BLE connection. Each response is identified by a [responseType] and can be serialized to and deserialized from
/// JSON format.
abstract class Response {
  /// Creates an instance of [Response] with the provided [responseType].
  ///
  /// The [responseType] parameter specifies the type of response being created.
  Response(this.responseType);

  /// Factory constructor to create a [Response] object from a JSON map.
  ///
  /// The [json] parameter is a map representing the JSON response received from the Brine device. The factory
  /// constructor determines the type of response based on the 'response' field in the JSON, and returns an instance
  /// of the appropriate subclass.
  ///
  /// Throws an [Exception] if the response type is unknown.
  factory Response.fromJson(Map<String, dynamic> json) {
    final String? responseKey = json['response'] as String?;

    if (responseKey == null) {
      throw Exception('Response type not found in JSON');
    } else if (responseKey == ResponseType.deviceId.responseKey) {
      return DeviceIdResponse.fromJson(json);
    } else if (responseKey == ResponseType.error.responseKey) {
      return ErrorResponse.fromJson(json);
    } else {
      throw Exception('Unknown response type: $responseKey');
    }
  }

  /// The type of response. This identifies the specific type of response being represented.
  final ResponseType responseType;

  /// Converts the response to a JSON-serializable map.
  ///
  /// This method should be overridden by subclasses to provide the specific JSON structure
  /// for each response type.
  Map<String, dynamic> toJson();
}
