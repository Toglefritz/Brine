/// An [Exception] thrown from errors in the [getDevice)] call.
class GetDeviceException implements Exception {
  final String message;

  GetDeviceException(this.message);

  @override
  String toString() {
    return 'GetDevicesException: $message';
  }
}