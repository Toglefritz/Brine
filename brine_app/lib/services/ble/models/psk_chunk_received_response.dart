import 'response.dart';
import 'response_type.dart';

/// A response indicating that a PSK chunk was successfully received by the Brine device.
///
/// This response is sent after each chunk of the PSK is received, allowing the mobile app
/// to track progress of the chunked transfer.
class PSKChunkReceivedResponse extends Response {
  /// Creates an instance of [PSKChunkReceivedResponse].
  PSKChunkReceivedResponse() : super(responseType: ResponseType.pskChunkReceived);

  @override
  Map<String, dynamic> toJson() {
    return {'response': responseType.responseKey};
  }
}
