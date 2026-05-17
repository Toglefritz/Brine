/// Performs a scan for nearby BLE device, filtered to show only devices with the specified service UUID.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_splendid_ble/central/models/scan_filter.dart';
import 'package:flutter_splendid_ble/central/splendid_ble_central.dart';
import 'package:flutter_splendid_ble/shared/models/ble_device.dart';
import 'package:flutter_splendid_ble/shared/models/bluetooth_permission_status.dart';
import 'package:flutter_splendid_ble/shared/models/bluetooth_status.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../components/buttons/light_button.dart';
import '../../../components/loaders/wave_loader.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/analytics/analytics.dart';
import '../../../services/ble/ble_communication_service.dart';
import '../../../theme/insets.dart';
import '../../errors/error_route.dart';
import '../../errors/models/error_type.dart';
import '../../setup/setup_route.dart';
import '../device_confirmation/device_confirmation_route.dart';

part 'scan_controller.dart';
part 'scan_view.dart';
part 'scan_view_none_found.dart';

/// Performs a scan for nearby BLE device, filtered to show only devices with the specified service UUID.
class ScanRoute extends StatefulWidget {
  /// Creates an instance of [ScanRoute].
  const ScanRoute({
    required this.excludedDeviceNames,
    this.ble,
    super.key,
  });

  /// A list of Brine device names to exclude from the Bluetooth scan. The [ScanController] will only take action when
  /// it detects a Brine [BleDevice] that is not among the excluded devices.
  final List<String> excludedDeviceNames;

  /// An optional [SplendidBleCentral] instance for BLE operations.
  ///
  /// When null, the controller uses [BleCommunicationService.ble]. Providing this in tests allows substitution with a
  /// mock.
  final SplendidBleCentral? ble;

  @override
  State<ScanRoute> createState() => ScanController();
}
