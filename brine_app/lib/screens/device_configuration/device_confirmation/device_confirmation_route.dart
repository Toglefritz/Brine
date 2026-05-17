/// Displays a page showing information about a Brine device that was detected during the Bluetooth scanning process.
library;

import 'package:flutter/material.dart';
import 'package:flutter_splendid_ble/shared/models/ble_device.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../components/buttons/light_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/analytics/analytics.dart';
import '../../../theme/insets.dart';
import '../device_connection/device_connection_route.dart';
import '../scan/scan_route.dart';

part 'device_confirmation_controller.dart';
part 'device_confirmation_view.dart';

/// Displays a page showing information about a Brine device that was detected during the Bluetooth scanning process.
/// The user can either confirm that this device is the one they wish to provision, in which case the provisioning flow
/// continues, or elect to choose to repeat the Bluetooth scan in an attempt to find a different Brine device.
class DeviceConfirmationRoute extends StatefulWidget {
  /// Creates and instance of [DeviceConfirmationRoute].
  const DeviceConfirmationRoute({
    required this.device,
    required this.excludedDevices,
    super.key,
  });

  /// The [BleDevice] detected by the Bluetooth scan that the user can confirm or deny is the one they wish to
  /// provision.
  final BleDevice device;

  /// A list of devices that were previously excluded from the Bluetooth scan. If the [device] is also excluded, it will
  /// be added to this prior list and the updated list passed back to the [ScanRoute].
  final List<String> excludedDevices;

  @override
  State<DeviceConfirmationRoute> createState() => DeviceConfirmationController();
}
