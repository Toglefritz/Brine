import 'package:flutter/material.dart';
import 'package:flutter_splendid_ble/shared/models/ble_device.dart';

import 'device_connection_controller.dart';

/// Connects, pairs, and bonds to the provided BLE device.
class DeviceConnectionRoute extends StatefulWidget {
  /// Creates an instance of [DeviceConnectionRoute].
  const DeviceConnectionRoute({
    required this.device,
    super.key,
  });

  /// The Brine BLE device that is the target of the provisioning flow.
  final BleDevice device;

  @override
  State<DeviceConnectionRoute> createState() => DeviceConnectionController();
}
