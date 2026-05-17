/// A screen that wraps up the provisioning process with final data sync to the cloud and BLE communication clearnup.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../components/buttons/light_button.dart';
import '../../../components/loaders/wave_loader.dart';
import '../../../extensions/json.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/analytics/analytics.dart';
import '../../../services/ble/ble_communication_service.dart';
import '../../../services/ble/models/command.dart';
import '../../../services/ble/models/command_type.dart';
import '../../../services/ble/models/response.dart';
import '../../../services/ble/models/response_type.dart';
import '../../../services/device_management/models/brine_device.dart';
import '../../../theme/insets.dart';
import '../../setup/setup_route.dart';

part 'provisioning_complete_controller.dart';
part 'provisioning_complete_view.dart';
part 'provisioning_complete_view_loading.dart';

/// This is the final step of the provisioning process. The app sends one last message to the Brine device to finalize
/// the provisioning process by uploading its sensor data to the cloud and then terminating the Bluetooth connection
/// Following this step, the Brine device will return to its normal operation mode, which involves maintaining a deep
/// sleep state most of the time.
class ProvisioningCompleteRoute extends StatefulWidget {
  /// Creates and instance of [ProvisioningCompleteRoute].
  const ProvisioningCompleteRoute({
    required this.bleCommunicationManager,
    required this.device,
    super.key,
  });

  /// A [BleCommunicationService] instance that manages the communication between the app and the Brine device.
  final BleCommunicationService bleCommunicationManager;

  /// The Brine device that is the target of the provisioning flow.
  final BrineDevice device;

  @override
  State<ProvisioningCompleteRoute> createState() => ProvisioningCompleteController();
}
