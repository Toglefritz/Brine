import 'response.dart';
import 'response_type.dart';

/// A class representing a response that indicates the Brine device has successfully connected to a WiFi network.
class WiFiConnectedResponse extends Response {
  /// Creates an instance of [WiFiConnectedResponse] with the provided [ssid].
  ///
  /// The [ssid] parameter specifies the SSID of the WiFi network to which the Brine device connected.
  WiFiConnectedResponse(this.ssid)
      : super(responseType: ResponseType.wifiConnected);

  /// Factory constructor to create a [WiFiConnectedResponse] object from a JSON map.
  ///
  /// The [json] parameter is a map representing the JSON response received from the Brine device.
  factory WiFiConnectedResponse.fromJson(Map<String, dynamic> json) {
    return WiFiConnectedResponse(json['ssid'] as String);
  }

  /// The device ID returned in the response.
  final String ssid;

  /// Converts the response to a JSON-serializable map.
  ///
  /// This method provides the specific JSON structure for the device ID response.
  @override
  Map<String, dynamic> toJson() {
    return {
      'response': responseType,
      'ssid': ssid,
    };
  }
}
