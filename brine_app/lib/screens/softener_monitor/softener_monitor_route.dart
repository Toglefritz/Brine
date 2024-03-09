import 'package:brine/screens/softener_monitor/softener_monitor_controller.dart';
import 'package:flutter/material.dart';

import '../../services/device_management/models/brine_device.dart';

/// Displays the level of salt remaining in the water softener and the battery life remaining on the Brine monitor.
class SoftenerMonitorRoute extends StatefulWidget {
  const SoftenerMonitorRoute({
    super.key,
    required this.devices,
  });

  /// A list of devices associated to the user's account.
  final List<BrineDevice> devices;

  @override
  State<SoftenerMonitorRoute> createState() => SoftenerMonitorController();
}
