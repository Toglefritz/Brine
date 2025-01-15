import 'package:flutter/material.dart';

import '../../../services/ble/ble_communication_service.dart';
import '../../../services/device_management/models/brine_device.dart';
import 'brine_installation_controller.dart';

/// This route route presents instructions to the user for installing a Brine device in their water softener. This is
/// necessary at this stage in the provisioning process because, before a reading can be taken from the distance sensor
/// on the Brine device, the device must be installed in the water softener. This route simply displays instructions
/// and waits for the user to confirm that the device is installed.
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
