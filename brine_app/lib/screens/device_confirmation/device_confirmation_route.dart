import 'package:flutter/material.dart';
import 'package:flutter_splendid_ble/shared/models/ble_device.dart';

import '../../services/device_management/models/brine_device.dart';
import 'device_confirmation_controller.dart';

/// Displays a page showing information about a Brine device that was detected during the Bluetooth scanning process.
/// The user can either confirm that this device is the one they wish to provision, in which case the provisioning
/// flow continues, or elect to choose to repeat the Bluetooth scan in an attempt to find a different Brine device.
class DeviceConfirmationRoute extends StatefulWidget {
  /// Creates and instance of [DeviceConfirmationRoute].
  const DeviceConfirmationRoute({
    required this.device,
    super.key,
  });

  /// The [BleDevice] detected by the Bluetooth scan that the user can confirm or deny is the one they wish to
  /// provision.
  final BleDevice device;

  @override
  State<DeviceConfirmationRoute> createState() => DeviceConfirmationController();
}
