import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/brine_device.dart';
import '../../services/device_management/device_management_service.dart';
import '../softener_monitor/softener_monitor_route.dart';
import '../welcome/welcome_route.dart';
import 'setup_route.dart';
import 'setup_view.dart';

/// Controller for the [SetupRoute].
class SetupController extends State<SetupRoute> {
  @override
  void initState() {
    // Perform setup for app usage
    _performSetup();

    super.initState();
  }

  /// Performs the setup necessary to proceed to the next route. This involves getting a list of the user's devices,
  /// assuming any have been added to the user's account, getting the details for each device, and handling errors
  /// related to these processes. If the user has no devices on their account, the app proceeds to the [WelcomeRoute].
  /// Otherwise, the app goes to the [SoftenerMonitorRoute].
  Future<void> _performSetup() async {
    List<BrineDevice>? deviceList;

    try {
      deviceList = await _getDevices();
    } catch (e) {
      debugPrint('Failed to perform setup with exception, $e');

      // TODO(Toglefritz): handle error, also sending info to Firebase would be good
    }

    // If there are no devices on the account, go to the [WelcomeRoute]
    if (deviceList == null || deviceList.isEmpty) {
      if (!mounted) return;

      await Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const WelcomeRoute(),
        ),
      );
    }
    // If there is at least one device on the account, go to the [SoftenerMonitorRoute].
    else {
      // Go to the water softener monitor route
      if (mounted) {
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => SoftenerMonitorRoute(
              devices: deviceList!,
            ),
          ),
        );
      }
    }
  }

  /// First, gets a list of [BrineDevice]s on the users account. Second, for each device on the user's account, get
  /// the salt and battery levels of the device.
  Future<List<BrineDevice>> _getDevices() async {
    debugPrint(
      'Getting devices for user, ${FirebaseAuth.instance.currentUser?.uid}',
    );

    final List<BrineDevice> deviceList = [];

    try {
      // Get the current user.
      final User user = FirebaseAuth.instance.currentUser!;

      // Get an instance of the device management service for the current user.
      final DeviceManagementService deviceManagementService = DeviceManagementService(user: user);

      // Get the device's on the user's account.
      final List<String> deviceIdList = await deviceManagementService.getUserDevices();

      // Get the salt and battery levels for each device.
      for (final String deviceId in deviceIdList) {
        final BrineDevice device = await deviceManagementService.getDeviceLevels(deviceId);
        deviceList.add(device);
      }
    } catch (e) {
      rethrow;
    }

    return deviceList;
  }

  @override
  Widget build(BuildContext context) => SetupView(this);
}
