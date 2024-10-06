import 'package:flutter/material.dart';

import '../../../models/brine_device.dart';
import '../../../services/ble/ble_communication_service.dart';
import 'provisioning_complete_controller.dart';

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
