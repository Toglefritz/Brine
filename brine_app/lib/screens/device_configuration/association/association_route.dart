import 'package:flutter/material.dart';

import '../../../services/device_management/models/brine_device.dart';
import '../../../services/ble/ble_communication_service.dart';
import 'association_controller.dart';

/// Associates the Brine device with the app.
class AssociationRoute extends StatefulWidget {
  /// Creates an instance of [AssociationRoute].
  const AssociationRoute({
    required this.device,
    required this.bleCommunicationManager,
    super.key,
  });

  /// The [BrineDevice] that is the target of the association process.
  final BrineDevice device;

  /// A [BleCommunicationService] instance that manages the communication between the app and the Brine device.
  final BleCommunicationService bleCommunicationManager;

  @override
  State<AssociationRoute> createState() => AssociationController();
}
