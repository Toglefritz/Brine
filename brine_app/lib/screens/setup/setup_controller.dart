import 'package:brine/screens/setup/setup_route.dart';
import 'package:brine/screens/setup/setup_view.dart';
import 'package:brine/screens/softener_monitor/softener_monitor_route.dart';
import 'package:brine/services/firebase/exceptions/get_device_exception.dart';
import 'package:brine/services/firebase/exceptions/get_user_devices_exception.dart';
import 'package:brine/services/firebase/get_device.dart';
import 'package:brine/services/firebase/get_user_devices.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/firebase/authentication/sign_out.dart';
import '../../services/firebase/models/brine_device.dart';

/// Controller for [SoftenerMonitorRoute].
class SetupController extends State<SetupRoute> {
  @override
  void initState() {
    // Perform setup for app usage
    performSetup();

    super.initState();
  }

  /// Performs the setup necessary to proceed to the next route. This involves
  /// getting a list of the user's devices, assuming any have been added to
  /// the user's account, getting the details for each device, and handling
  /// errors related to these processes. If the user has no devices on their
  /// account, the app proceeds to the [AddDeviceRoute]. Otherwise, the app
  /// goes to the [SoftenerMonitorRoute].
  Future<void> performSetup() async {
    List<BrineDevice>? deviceList;

    try {
      deviceList = await _getDevices();
    } on GetUserDevicesException {
      debugPrint('Failed to get user devices');

      // TODO is this how we want to handle the error?
      signOut();
    } on GetDeviceException {
      debugPrint('Failed to get device details');

      // TODO handle error
    } catch (e) {
      debugPrint('Failed to perform setup with exception, $e');

      // TODO handle error
    }

    // Check if there are any devices on the account
    if (deviceList == null || deviceList.isEmpty) {
      // TODO go to AddDeviceRoute
      // TODO remove this method once AddDeviceRoute exists
      signOut();
    } else {
      // Go to the water softener monitor route
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => SoftenerMonitorRoute(
              devices: deviceList!,
            ),
          ),
        );
      }
    }
  }

  /// First, gets a list of [BrineDevice]s on the users account. Second, for
  /// each device on the user's account, get the salt and battery levels
  /// of the device.
  Future<List<BrineDevice>> _getDevices() async {
    debugPrint('Getting devices for user, ${FirebaseAuth.instance.currentUser?.uid}');

    List<BrineDevice> deviceList = [];

    try {
      // Get the device's on the user's account
      List<String> deviceIdList = await getUserDevices();

      for (String deviceId in deviceIdList) {
        BrineDevice device = await getDevice(deviceId);
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
