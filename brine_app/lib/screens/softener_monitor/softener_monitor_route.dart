import 'package:brine/screens/softener_monitor/softener_monitor_controller.dart';
import 'package:flutter/material.dart';

/// Displays the level of salt remaining in the water softener and the battery life remaining on the Brine monitor.
class SoftenerMonitorRoute extends StatefulWidget {
  const SoftenerMonitorRoute({super.key});

  @override
  State<SoftenerMonitorRoute> createState() => SoftenerMonitorController();
}
