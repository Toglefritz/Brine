import 'package:flutter/material.dart';

import 'scan_controller.dart';

/// Performs a scan for nearby BLE device, filtered to show only devices with the specified service UUID.
class ScanRoute extends StatefulWidget {
  /// Creates an instance of [ScanRoute].
  const ScanRoute({super.key});

  @override
  State<ScanRoute> createState() => ScanController();
}
