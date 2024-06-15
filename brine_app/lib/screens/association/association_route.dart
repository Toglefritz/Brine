import 'package:flutter/material.dart';

import 'association_controller.dart';

/// Associates the Brine device with the app.
class AssociationRoute extends StatefulWidget {
  /// Creates an instance of [AssociationRoute].
  const AssociationRoute({
    required this.deviceName,
    required this.deviceId,
    super.key,
  });

  /// The name of the Brine BLE device, which is derived from the device's MAC address.
  final String deviceName;

  /// The Brine BLE device that is the target of the provisioning flow.
  final String deviceId;

  @override
  State<AssociationRoute> createState() => AssociationController();
}
