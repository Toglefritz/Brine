import 'response.dart';
import 'response_type.dart';

/// A class representing a response containing the public key.
///
/// Brine devices are equipped with a cryptographic coprocessor that holds a public-private key pair. The public key is
/// used to establish secure communication between the Brine device and the app and between the Brine device and the
/// Brine cloud.
///
/// The public key from the cryptographic coprocessor is in binary format. However, the Brine device converts this
/// to a base64-encoded string before sending it to the app.
class PublicKeyResponse extends Response {
  /// Creates an instance of [PublicKeyResponse] with the provided [publicKey].
  ///
  /// The [publicKey] parameter specifies the device ID returned by the Brine device.
  PublicKeyResponse(this.publicKey)
      : super(responseType: ResponseType.publicKey);

  /// Factory constructor to create a [PublicKeyResponse] object from a JSON map.
  ///
  /// The [json] parameter is a map representing the JSON response received from the Brine device.
  factory PublicKeyResponse.fromJson(Map<String, dynamic> json) {
    return PublicKeyResponse(json['public_key'] as String);
  }

  /// The public key returned in the response.
  final String publicKey;

  /// Converts the response to a JSON-serializable map.
  ///
  /// This method provides the specific JSON structure for the device ID response.
  @override
  Map<String, dynamic> toJson() {
    return {
      'response': responseType,
      'public_key': publicKey,
    };
  }
}
