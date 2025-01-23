import 'package:flutter/material.dart';

import '../../services/authentication/authentication_service.dart';
import '../authentication/onboarding/onboarding_route.dart';
import '../device_configuration/scan/scan_route.dart';
import 'softener_monitor_overdue_view.dart';
import 'softener_monitor_route.dart';
import 'softener_monitor_view.dart';

/// Controller for [SoftenerMonitorRoute].
class SoftenerMonitorController extends State<SoftenerMonitorRoute> {
  /// Handles taps on the "logout" button.
  Future<void> onLogout() async {
    // TODO(Toglefritz): analytics tag

    await AuthenticationService.signOut();

    if (!mounted) return;
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const OnboardingRoute(),
      ),
    );
  }

  /// A getter for the last update time of the device, in the form, MM/DD/YYYY HH:MM:SS.
  String get lastUpdateTime {
    // Get the last update time of the device.
    final DateTime lastUpdate = widget.devices.first.lastUpdatedTimestamp;

    // Format the last update time.
    return '${lastUpdate.month}/${lastUpdate.day}/${lastUpdate.year}';
  }

  /// Called when the "Reconnect" button is tapped.
  ///
  /// Brine devices may go offline for a number of reasons. When the last update received from a Brine device is
  /// overdue, the user may need to take actions to reconnect the device. This function is called when the user taps
  /// the "Reconnect" button.
  Future<void> onReconnectDevice() async {
    // Get a list of device names to be excluded from the Bluetooth scan on the next screen.
    final List<String> deviceExclusionList = [
      ...widget.devices.map((device) => device.name),
    ];

    await Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => ScanRoute(
          excludedDeviceNames: deviceExclusionList,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO(Toglefritz): check for the currently selected device
    if (widget.devices.first.isUpdateOverdue) {
      return SoftenerMonitorOverdueView(this);
    } else {
      return SoftenerMonitorView(this);
    }
  }
}
