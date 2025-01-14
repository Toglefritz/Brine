import 'response.dart';
import 'response_type.dart';

/// A class representing a response confirming that the Brine device has successfully received and saved the
/// pre-shared key (PSK) to non-volatile storage (NVS).
class PSKTransferredResponse extends Response {
  /// Creates an instance of [PSKTransferredResponse].
  PSKTransferredResponse() : super(responseType: ResponseType.pskTransferred);

  /// Converts the response to a JSON-serializable map.
  ///
  /// This method provides the specific JSON structure for the device ID response.
  @override
  Map<String, dynamic> toJson() {
    return {
      'response': responseType,
    };
  }
}
