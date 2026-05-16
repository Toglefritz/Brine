import 'package:brine/screens/setup/setup_route.dart';
import 'package:brine/services/authentication/exceptions/authentication_exception.dart';
import 'package:brine/services/device_management/device_management_service.dart';
import 'package:brine/services/device_management/models/brine_device.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// A fake [DeviceManagementService] that returns preconfigured device lists for testing.
///
/// Allows tests to control what `getUserDevices` returns without making HTTP calls.
class FakeDeviceManagementService extends DeviceManagementService {
  /// Creates a [FakeDeviceManagementService] with the given [devices] to return, or an [exception] to throw.
  FakeDeviceManagementService({
    required super.user,
    this.devices = const [],
    this.exception,
  });

  /// The list of devices to return from [getUserDevices].
  final List<BrineDevice> devices;

  /// An optional exception to throw from [getUserDevices] instead of returning devices.
  final Exception? exception;

  @override
  Future<List<BrineDevice>> getUserDevices() async {
    if (exception != null) {
      throw exception!;
    }
    return devices;
  }
}

/// Factory function that creates a [FakeDeviceManagementService] returning the given [devices].
///
/// Use this with [SetupRoute.deviceManagementServiceFactory] to inject controlled behavior in tests.
DeviceManagementService Function(User user) fakeDeviceManagementServiceFactory({
  List<BrineDevice> devices = const [],
  Exception? exception,
}) {
  return (User user) => FakeDeviceManagementService(
    user: user,
    devices: devices,
    exception: exception,
  );
}

/// Factory function that creates a [FakeDeviceManagementService] which throws an [AuthenticationException].
DeviceManagementService Function(User user) throwingAuthExceptionFactory({
  String message = 'Authentication failed',
}) {
  return (User user) => FakeDeviceManagementService(
    user: user,
    exception: AuthenticationException(message),
  );
}
