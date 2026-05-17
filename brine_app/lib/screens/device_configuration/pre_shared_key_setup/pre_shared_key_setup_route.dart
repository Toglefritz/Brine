/// Requests a pre-shared key (PSK) from the Firebase backend and transfers the PSK to the Brine device.
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../components/loaders/wave_loader.dart';
import '../../../extensions/json.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/analytics/analytics.dart';
import '../../../services/authentication/auth_session.dart';
import '../../../services/authentication/firebase_auth_session.dart';
import '../../../services/ble/ble_communication_service.dart';
import '../../../services/ble/models/command.dart';
import '../../../services/ble/models/command_type.dart';
import '../../../services/ble/models/response.dart';
import '../../../services/ble/models/response_type.dart';
import '../../../services/device_management/device_management_service.dart';
import '../../../services/device_management/models/brine_device.dart';
import '../../../services/device_management/models/pre_shared_key.dart';
import '../../../theme/insets.dart';
import '../wifi_setup/wifi_setup_route.dart';

part 'pre_shared_key_setup_controller.dart';
part 'pre_shared_key_setup_view.dart';

/// Requests a pre-shared key (PSK) from the Firebase backend and transfers the PSK to the Brine device.
///
/// This route is responsible for the following:
///
/// 1. Requesting a pre-shared key (PSK) from the Firebase backend.
/// 2. Transferring the PSK to the Brine device.
///
/// After the PSK is transferred to the Brine device, the app will navigate to the `WiFiSetupRoute`.
///
/// Dependencies can be injected for testing. When no overrides are provided, the route uses production implementations.
class PreSharedKeySetupRoute extends StatefulWidget {
  /// Creates an instance of [PreSharedKeySetupRoute].
  const PreSharedKeySetupRoute({
    required this.device,
    required this.bleCommunicationManager,
    this.authSession = const FirebaseAuthSession(),
    this.deviceManagementServiceFactory,
    super.key,
  });

  /// The [BrineDevice] that is the target of the device configuration process.
  final BrineDevice device;

  /// A [BleCommunicationService] instance that manages the communication between the app and the Brine device.
  final BleCommunicationService bleCommunicationManager;

  /// Provides access to the current authenticated user.
  ///
  /// Defaults to [FirebaseAuthSession], which delegates to `FirebaseAuth.instance`.
  final AuthSession authSession;

  /// An optional factory for creating a [DeviceManagementService] given a [User].
  ///
  /// When null, the controller creates a standard [DeviceManagementService] instance.
  final DeviceManagementService Function(User user)? deviceManagementServiceFactory;

  @override
  State<PreSharedKeySetupRoute> createState() => PreSharedKeySetupController();
}
