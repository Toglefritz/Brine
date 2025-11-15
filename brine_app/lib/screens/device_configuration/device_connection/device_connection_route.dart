import 'package:flutter/material.dart';
import 'package:flutter_splendid_ble/shared/models/ble_device.dart';

import 'device_connection_controller.dart';

/// Connects, pairs, and bonds to the provided BLE device.
///
/// This route performs a series of steps, in order, that are required to establish secure Bluetooth communication with
/// the Brine device. This communication is required for the remainder of the provisioning process. The steps performed
/// by this route are:
///
/// 1.  Establishing a connection to the [BleDevice].
/// 2.  Performing service and characteristic discovery.
/// 3.  Pairing and bonding with the device.
/// 4.  Obtaining the device ID of the Brine device.
///
/// After successfully completing the above steps, the app moves on to associating the Brine device to the user's
/// account.
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
