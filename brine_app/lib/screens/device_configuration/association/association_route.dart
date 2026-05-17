/// Associates the Brine device with the app.
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../components/loaders/wave_loader.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/authentication/auth_session.dart';
import '../../../services/authentication/firebase_auth_session.dart';
import '../../../services/ble/ble_communication_service.dart';
import '../../../services/device_management/device_management_service.dart';
import '../../../services/device_management/models/brine_device.dart';
import '../../../theme/insets.dart';
import '../pre_shared_key_setup/pre_shared_key_setup_route.dart';

part 'association_controller.dart';
part 'association_view.dart';

/// Associates the Brine device with the app.
///
/// Dependencies can be injected for testing. When no overrides are provided, the route uses production implementations.
class AssociationRoute extends StatefulWidget {
  /// Creates an instance of [AssociationRoute].
  const AssociationRoute({
    required this.device,
    required this.bleCommunicationManager,
    this.authSession = const FirebaseAuthSession(),
    this.deviceManagementServiceFactory,
    super.key,
  });

  /// The [BrineDevice] that is the target of the association process.
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
  State<AssociationRoute> createState() => AssociationController();
}
