import 'package:flutter/material.dart';

import '../../services/device_management/models/brine_device.dart';
import 'softener_monitor_controller.dart';

/// Displays the level of salt remaining in the water softener and the battery life remaining on the Brine monitor.
class SoftenerMonitorRoute extends StatefulWidget {
  /// Creates an instance of [SoftenerMonitorRoute].
  const SoftenerMonitorRoute({
    required this.devices,
    super.key,
  });

  /// A list of devices associated to the user's account.
  final List<BrineDevice> devices;

  @override
  State<SoftenerMonitorRoute> createState() => SoftenerMonitorController();
}
