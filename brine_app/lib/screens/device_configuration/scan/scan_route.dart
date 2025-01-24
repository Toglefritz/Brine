import 'package:flutter/material.dart';
import 'package:flutter_splendid_ble/shared/models/ble_device.dart';

import 'scan_controller.dart';

/// Performs a scan for nearby BLE device, filtered to show only devices with the specified service UUID.
class ScanRoute extends StatefulWidget {
  /// Creates an instance of [ScanRoute].
  const ScanRoute({
    required this.excludedDeviceNames,
    super.key,
  });

  /// A list of Brine device names to exclude from the Bluetooth scan. The [ScanController] will only take action when
  /// it detects a Brine [BleDevice] that is not among the excluded devices.
  final List<String> excludedDeviceNames;

  @override
  State<ScanRoute> createState() => ScanController();
}
