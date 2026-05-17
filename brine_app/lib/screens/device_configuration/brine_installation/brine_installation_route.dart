/// This route route presents instructions to the user for installing a Brine device in their water softener.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../components/buttons/light_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/analytics/analytics.dart';
import '../../../services/ble/ble_communication_service.dart';
import '../../../services/device_management/models/brine_device.dart';
import '../../../theme/insets.dart';
import '../appliance_measurement/appliance_measurement_route.dart';

part 'brine_installation_controller.dart';
part 'brine_installation_view.dart';

/// This route route presents instructions to the user for installing a Brine device in their water softener. This is
/// necessary at this stage in the provisioning process because, before a reading can be taken from the distance sensor
/// on the Brine device, the device must be installed in the water softener. This route simply displays instructions and
/// waits for the user to confirm that the device is installed.
class BrineInstallationRoute extends StatefulWidget {
  /// Creates and instance of [BrineInstallationRoute].
  const BrineInstallationRoute({
    required this.bleCommunicationManager,
    required this.device,
    super.key,
  });

  /// A [BleCommunicationService] instance that manages the communication between the app and the Brine device.
  final BleCommunicationService bleCommunicationManager;

  /// The Brine device that is the target of the provisioning flow.
  final BrineDevice device;

  @override
  State<BrineInstallationRoute> createState() => BrineInstallationController();
}
