/// An [Exception] thrown from errors in the [getUserDevices] call.
class GetUserDevicesException implements Exception {
  final String message;

  GetUserDevicesException(this.message);

  @override
  String toString() {
    return 'GetDevicesException: $message';
  }
}