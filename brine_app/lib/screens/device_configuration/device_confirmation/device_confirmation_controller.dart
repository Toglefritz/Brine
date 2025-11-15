import 'package:flutter/material.dart';

import '../../../services/analytics/analytics.dart';
import '../device_connection/device_connection_route.dart';
import '../scan/scan_route.dart';
import 'device_confirmation_route.dart';
import 'device_confirmation_view.dart';

/// Controller for [DeviceConfirmationRoute].
class DeviceConfirmationController extends State<DeviceConfirmationRoute> {
  /// Handles taps on the "Continue" button.
  ///
  /// The "continue" button in the [DeviceConfirmationView] is used to confirm that the targeted Brine module is the one
  /// the user intends to provision. This confirmation allows the provisioning process to continue to the next step.
  void onContinuePressed() {
    Analytics.trackEvent(eventName: 'device_confirmation_denied');

    // Proceed with the selected device.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => DeviceConnectionRoute(
          device: widget.device,
        ),
      ),
    );
  }

  /// Handles taps on the "Choose Another" button.
  ///
  /// The "choose another" button in the [DeviceConfirmationView] is used to deny that the targeted Brine module is the
  /// correct one for provisioning. This denial causes the provisioning process to go back to the Bluetooth scan so a
  /// different Brine module can be selected. The module that is currently targeted is excluded from the next Bluetooth
  /// search, along with any other devices where were excluded previously.
  void onChooseAnotherPressed() {
    Analytics.trackEvent(eventName: 'device_confirmation_denied');

    // Add the discovered, but rejected, device to the list of excluded devices.
    final List<String> deviceExclusionList = [
      ...widget.excludedDevices,
      widget.device.name ?? '',
    ];

    // Go back to the scan route.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => ScanRoute(
          excludedDeviceNames: deviceExclusionList,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => DeviceConfirmationView(this);
}
