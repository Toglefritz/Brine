import 'package:flutter/material.dart';

import '../../services/analytics/analytics.dart';
import '../account/account_route.dart';
import '../device_configuration/scan/scan_route.dart';
import 'softener_monitor_overdue_view.dart';
import 'softener_monitor_route.dart';
import 'softener_monitor_view.dart';

/// Controller for [SoftenerMonitorRoute].
class SoftenerMonitorController extends State<SoftenerMonitorRoute> {
  /// Handles taps on the "account" button in the app bar menu. This simply navigates to the account route.
  Future<void> onAccountTap() async {
    Analytics.trackEvent(eventName: 'account_menu_tap');

    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => AccountRoute(
          devices: widget.devices,
        ),
      ),
    );
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
