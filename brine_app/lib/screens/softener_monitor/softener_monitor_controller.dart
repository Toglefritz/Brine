import 'package:flutter/material.dart';

import '../../services/analytics/analytics.dart';
import '../../services/device_management/models/brine_device.dart';
import '../account/account_route.dart';
import '../device_configuration/scan/scan_route.dart';
import 'softener_monitor_overdue_view.dart';
import 'softener_monitor_route.dart';
import 'softener_monitor_view.dart';

/// Controller for [SoftenerMonitorRoute].
class SoftenerMonitorController extends State<SoftenerMonitorRoute> {
  /// The currently selected Brine monitor device.
  ///
  /// This route displays information about one Brine device at a time. Therefore, if a user has more than one Brine
  /// device, they can select the device for which this route will display information. This variable stores the
  /// currently selected device.
  late BrineDevice selectedDevice;

  @override
  void initState() {
    Analytics.trackPageView('softener_monitor');

    // By default, select the first device in the list.
    selectedDevice = widget.devices.first;

    super.initState();
  }

  /// Handles changing the currently selected device.
  void onDeviceSelected(BrineDevice device) {
    setState(() {
      selectedDevice = device;
    });
  }

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
  /// overdue, the user may need to take actions to reconnect the device. This function is called when the user taps the
  /// "Reconnect" button.
  Future<void> onReconnectDevice() async {
    // Get a list of device names to be excluded from the Bluetooth scan on the next screen.
    final List<String> deviceExclusionList = [
      ...widget.devices.map((BrineDevice device) => device.name),
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
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child:
          selectedDevice.isUpdateOverdue ? SoftenerMonitorOverdueView(state: this) : SoftenerMonitorView(state: this),
    );
  }
}
