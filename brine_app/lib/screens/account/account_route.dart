/// This route displays information about the user's account including their devices and account settings.
library;

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../components/buttons/light_button.dart';
import '../../l10n/app_localizations.dart';
import '../../services/analytics/analytics.dart';
import '../../services/authentication/auth_session.dart';
import '../../services/authentication/authentication_service.dart';
import '../../services/authentication/firebase_auth_session.dart';
import '../../services/device_management/device_management_service.dart';
import '../../services/device_management/models/brine_device.dart';
import '../../theme/insets.dart';
import '../authentication/onboarding/onboarding_route.dart';
import '../welcome/welcome_route.dart';

part 'components/user_avatar.dart';
part 'account_controller.dart';
part 'account_view.dart';
part 'edit_profile_view.dart';
part 'components/device_list.dart';
part 'components/expandable_device_card.dart';

/// Displays information about the user's account including their devices and account settings.
///
/// Dependencies can be injected for testing. When no overrides are provided, the route uses production implementations
/// that delegate to Firebase.
class AccountRoute extends StatefulWidget {
  /// Creates an instance of [AccountRoute].
  ///
  /// The [devices] parameter is required. All other parameters are optional and default to production implementations.
  const AccountRoute({
    required this.devices,
    this.authSession = const FirebaseAuthSession(),
    this.deviceManagementServiceFactory,
    this.signOut,
    this.deleteUserDocument,
    super.key,
  });

  /// A list of Brine devices on the user's account.
  final List<BrineDevice> devices;

  /// Provides access to the current authenticated user.
  ///
  /// Defaults to [FirebaseAuthSession], which delegates to `FirebaseAuth.instance`.
  final AuthSession authSession;

  /// An optional factory for creating a [DeviceManagementService] given a [User].
  ///
  /// When null, the controller creates a standard [DeviceManagementService] instance.
  final DeviceManagementService Function(User user)? deviceManagementServiceFactory;

  /// An optional override for the sign-out operation.
  ///
  /// When null, the controller calls [AuthenticationService.signOut]. Providing this in tests allows verification of
  /// logout behavior without Firebase platform dependencies.
  final Future<void> Function()? signOut;

  /// An optional override for the delete-user-document operation.
  ///
  /// When null, the controller creates an [AuthenticationService] and calls `deleteUserDocument`. Providing this in
  /// tests allows verification of account deletion behavior without Firebase platform dependencies.
  final Future<void> Function(User user)? deleteUserDocument;

  @override
  State<AccountRoute> createState() => AccountController();
}
