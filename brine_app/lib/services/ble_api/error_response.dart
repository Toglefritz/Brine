import 'response.dart';

/// A class representing an error response.
class ErrorResponse extends Response {
  /// Creates an instance of [ErrorResponse] with the provided [message].
  ///
  /// The [message] parameter specifies the error message returned by the Brine device.
  ErrorResponse(this.message) : super('error');

  /// Factory constructor to create an [ErrorResponse] object from a JSON map.
  ///
  /// The [json] parameter is a map representing the JSON response received from the Brine device.
  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(json['message'] as String);
  }

  /// The error message returned in the response.
  final String message;

  /// Converts the response to a JSON-serializable map.
  ///
  /// This method provides the specific JSON structure for the error response.
  @override
  Map<String, dynamic> toJson() {
    return {
      'response': responseType,
      'message': message,
    };
  }
}