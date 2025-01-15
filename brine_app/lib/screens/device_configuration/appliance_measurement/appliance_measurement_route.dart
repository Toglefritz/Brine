import 'package:flutter/material.dart';

import '../../../services/ble/ble_communication_service.dart';
import '../../../services/device_management/models/brine_device.dart';
import 'appliance_measurement_controller.dart';

/// The Brine is equipped with a distance sensor that enables it to measure the distance between the monitor and the
/// level of salt in the water softener. However, in order to convert this distance measurement to a percentage of salt
/// remaining in the water softener, the Brine system needs to know the height of the water softener. This route
/// prompts the user to measure the height of the water softener and input this value into the app. The app then sends
/// this value to the Firestore backend where it is stored and used to convert the distance measurement to a percentage.
class ApplianceMeasurementRoute extends StatefulWidget {
  /// Creates and instance of [ApplianceMeasurementRoute].
  const ApplianceMeasurementRoute({
    required this.bleCommunicationManager,
    required this.device,
    super.key,
  });

  /// A [BleCommunicationService] instance that manages the communication between the app and the Brine device.
  final BleCommunicationService bleCommunicationManager;

  /// The Brine device that is the target of the provisioning flow.
  final BrineDevice device;

  @override
  State<ApplianceMeasurementRoute> createState() =>
      ApplianceMeasurementController();
}
