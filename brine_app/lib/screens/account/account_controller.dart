import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/analytics/analytics.dart';
import '../../services/authentication/authentication_service.dart';
import '../../services/device_management/device_management_service.dart';
import '../../services/device_management/models/brine_device.dart';
import '../welcome/welcome_route.dart';
import 'account_route.dart';
import 'account_view.dart';

/// Controller for the [AccountRoute].
class AccountController extends State<AccountRoute> {
  /// A convenience getter for the Firebase Auth user object.
  User? get user => FirebaseAuth.instance.currentUser;

  /// A convenience getter for the user's initials.
  String get userInitials {
    if (user == null) {
      return '';
    }

    // Split the user's display name their first and last names.
    final List<String> nameParts = user!.displayName!.split(' ');

    // Get the first letter of the user's first name.
    final String firstName = nameParts.first;

    // Get the first letter of the user's last name, if it exists.
    final String lastName = nameParts.length > 1 ? nameParts.last : '';

    // Return a string consisting of the first letters of the user's first and last names.
    return '${firstName[0]}${lastName[0]}';
  }

  /// Handles requests to remove a device from an account.
  ///
  /// This function first presents a dialog to the user to confirm that they wish to remove the Brine device from their
  /// account. If they choose the affirmative option, the device is removed from the account using a request to a
  /// Firebase Functions endpoint.
  Future<void> removeDevice(String deviceId) async {
    // Present a dialog to the user to confirm that they wish to remove the device.
    final bool? didConfirm = await AccountView.showRemoveDeviceConfirmationDialog(
      context: context,
      deviceId: deviceId,
    );

    // If the user confirmed that they wish to remove the device, remove the device.
    if (didConfirm ?? false) {
      // Get the current user.
      final User user = FirebaseAuth.instance.currentUser!;

      // Remove the device from the user's account.
      try {
        await DeviceManagementService(user: user).removeDeviceFromAccount(deviceId: deviceId);
      } catch (e) {
        debugPrint('Failed to remove device with exception, $e');

        // TODO(Toglefritz): Handle the failure to remove the device from the account.
      }

      // Create a new list of devices that excludes the device that was removed.
      final List<BrineDevice> updatedDevices = widget.devices
        ..removeWhere((BrineDevice device) => device.deviceId == deviceId);

      // If the user has just removed the last device from their account, navigate back to the WelcomeRoute.
      if (updatedDevices.isEmpty) {
        if (!mounted) return;
        await Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const WelcomeRoute(),
          ),
          (Route<dynamic> route) => false,
        );
        return;
      }
      // Otherwise, refresh this route.
      else {
        // Refresh this route.
        if (!mounted) return;
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => AccountRoute(devices: updatedDevices),
          ),
        );
      }
    }
  }

  /// Handles taps on the "logout" button.
  Future<void> logout() async {
    Analytics.trackLogout();

    await AuthenticationService.signOut();
  }

  @override
  Widget build(BuildContext context) => AccountView(this);
}
