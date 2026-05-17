/// This screen allows the user to configure the height of the water softener.
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../components/buttons/light_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/unit_of_measurement.dart';
import '../../../services/analytics/analytics.dart';
import '../../../services/authentication/auth_session.dart';
import '../../../services/authentication/firebase_auth_session.dart';
import '../../../services/ble/ble_communication_service.dart';
import '../../../services/device_management/device_management_service.dart';
import '../../../services/device_management/models/brine_device.dart';
import '../../../theme/insets.dart';
import '../../../values/image_asset.dart';
import '../brine_installation/brine_installation_route.dart';
import '../provisioning_complete/provisioning_complete_route.dart';

part 'appliance_measurement_controller.dart';
part 'appliance_measurement_view.dart';

/// The Brine is equipped with a distance sensor that enables it to measure the distance between the monitor and the
/// level of salt in the water softener. However, in order to convert this distance measurement to a percentage of salt
/// remaining in the water softener, the Brine system needs to know the height of the water softener. This route prompts
/// the user to measure the height of the water softener and input this value into the app. The app then sends this
/// value to the Firestore backend where it is stored and used to convert the distance measurement to a percentage.
///
/// Dependencies can be injected for testing. When no overrides are provided, the route uses production implementations.
class ApplianceMeasurementRoute extends StatefulWidget {
  /// Creates and instance of [ApplianceMeasurementRoute].
  const ApplianceMeasurementRoute({
    required this.bleCommunicationManager,
    required this.device,
    this.authSession = const FirebaseAuthSession(),
    this.deviceManagementServiceFactory,
    super.key,
  });

  /// A [BleCommunicationService] instance that manages the communication between the app and the Brine device.
  final BleCommunicationService bleCommunicationManager;

  /// The Brine device that is the target of the provisioning flow.
  final BrineDevice device;

  /// Provides access to the current authenticated user.
  ///
  /// Defaults to [FirebaseAuthSession], which delegates to `FirebaseAuth.instance`.
  final AuthSession authSession;

  /// An optional factory for creating a [DeviceManagementService] given a [User].
  ///
  /// When null, the controller creates a standard [DeviceManagementService] instance.
  final DeviceManagementService Function(User user)? deviceManagementServiceFactory;

  @override
  State<ApplianceMeasurementRoute> createState() => ApplianceMeasurementController();
}
