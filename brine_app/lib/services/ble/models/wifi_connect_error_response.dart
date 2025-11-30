import 'response.dart';
import 'response_type.dart';

/// A class representing a WiFi connection error response from the Brine device.
///
/// This response is sent when the device fails to connect to a WiFi network.
class WiFiConnectErrorResponse extends Response {
  /// Creates an instance of [WiFiConnectErrorResponse] with the provided [message].
  ///
  /// The [message] parameter specifies the error message describing why the connection failed.
  WiFiConnectErrorResponse(this.message) : super(responseType: ResponseType.wifiConnectError);

  /// Factory constructor to create a [WiFiConnectErrorResponse] object from a JSON map.
  ///
  /// The [json] parameter is a map representing the JSON response received from the Brine device.
  factory WiFiConnectErrorResponse.fromJson(Map<String, dynamic> json) {
    return WiFiConnectErrorResponse(json['message'] as String);
  }

  /// The error message describing why the WiFi connection failed.
  final String message;

  /// Converts the response to a JSON-serializable map.
  @override
  Map<String, dynamic> toJson() {
    return {'response': responseType.responseKey, 'message': message};
  }
}
