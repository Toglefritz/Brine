/// Connects, pairs, and bonds to the provided BLE device.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_splendid_ble/central/models/ble_characteristic.dart';
import 'package:flutter_splendid_ble/central/models/ble_connection_state.dart';
import 'package:flutter_splendid_ble/central/models/ble_service.dart';
import 'package:flutter_splendid_ble/central/splendid_ble_central.dart';
import 'package:flutter_splendid_ble/shared/models/ble_device.dart';

import '../../../components/loaders/wave_loader.dart';
import '../../../extensions/json.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/analytics/analytics.dart';
import '../../../services/ble/ble_communication_service.dart';
import '../../../services/ble/models/command.dart';
import '../../../services/ble/models/command_type.dart';
import '../../../services/ble/models/device_id_response.dart';
import '../../../services/ble/models/response.dart';
import '../../../services/device_management/models/brine_device.dart';
import '../../../theme/insets.dart';
import '../../errors/error_route.dart';
import '../../errors/models/error_type.dart';
import '../association/association_route.dart';

part 'device_connection_controller.dart';
part 'device_connection_view.dart';

/// Connects, pairs, and bonds to the provided BLE device.
///
/// This route performs a series of steps required to establish secure Bluetooth communication with the Brine device:
///
/// 1. Establishing a connection to the [BleDevice].
/// 2. Performing service and characteristic discovery.
/// 3. Pairing and bonding with the device.
/// 4. Obtaining the device ID of the Brine device.
///
/// Dependencies can be injected for testing. When no overrides are provided, the route uses production implementations.
class DeviceConnectionRoute extends StatefulWidget {
  /// Creates an instance of [DeviceConnectionRoute].
  const DeviceConnectionRoute({
    required this.device,
    this.ble,
    super.key,
  });

  /// The Brine BLE device that is the target of the provisioning flow.
  final BleDevice device;

  /// An optional [SplendidBleCentral] instance for BLE operations.
  ///
  /// When null, the controller creates a new instance. Providing this in tests allows substitution with a mock.
  final SplendidBleCentral? ble;

  @override
  State<DeviceConnectionRoute> createState() => DeviceConnectionController();
}
