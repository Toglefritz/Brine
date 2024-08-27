import 'package:flutter/material.dart';

import '../../../services/ble/ble_communication_service.dart';
import 'association_controller.dart';

/// Associates the Brine device with the app.
class AssociationRoute extends StatefulWidget {
  /// Creates an instance of [AssociationRoute].
  const AssociationRoute({
    required this.deviceName,
    required this.deviceId,
    required this.publicKey,
    required this.bleCommunicationManager,
    super.key,
  });

  /// The name of the Brine BLE device, which is derived from the device's MAC address.
  final String deviceName;

  /// The device ID of the Brine BLE device that is the target of the provisioning flow.
  final String deviceId;

  /// The public key held by the cryptographic coprocessor of the Brine device. The public key from the cryptographic
  /// coprocessor is in binary format. However, the Brine device converts this to a base64-encoded string before sending
  /// it to the app.
  final String publicKey;

  /// A [BleCommunicationService] instance that manages the communication between the app and the Brine device.
  final BleCommunicationService bleCommunicationManager;

  @override
  State<AssociationRoute> createState() => AssociationController();
}
