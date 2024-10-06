import 'response.dart';
import 'response_type.dart';

/// A class representing a response confirming that the Brine device has successfully concluded the provisioning
/// process.
class ProvisioningCompleteResponse extends Response {
  /// Creates an instance of [ProvisioningCompleteResponse].
  ProvisioningCompleteResponse() : super(responseType: ResponseType.provisioningComplete);

  /// Factory constructor to create a [ProvisioningCompleteResponse] object from a JSON map.
  factory ProvisioningCompleteResponse.fromJson() {
    return ProvisioningCompleteResponse();
  }

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
