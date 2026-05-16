/// Displays the level of salt remaining in the water softener and the battery life remaining on the Brine monitor.
library;

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../components/buttons/light_button.dart';
import '../../components/dashed_outlines/dashed_divider.dart';
import '../../l10n/app_localizations.dart';
import '../../services/analytics/analytics.dart';
import '../../services/device_management/models/brine_device.dart';
import '../../theme/insets.dart';
import '../account/account_route.dart';
import '../device_configuration/scan/scan_route.dart';

part 'softener_monitor_controller.dart';
part 'softener_monitor_view.dart';
part 'softener_monitor_overdue_view.dart';
part 'components/softener_monitor_app_bar.dart';
part 'components/battery_indicator.dart';
part 'components/wave_progress_indicator.dart';

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
