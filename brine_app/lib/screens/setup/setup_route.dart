/// Performs the setup necessary to proceed to the next route.
library;

import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../components/loaders/wave_loader.dart';
import '../../extensions/brightness_extensions.dart';
import '../../services/analytics/analytics.dart';
import '../../services/authentication/auth_session.dart';
import '../../services/authentication/exceptions/authentication_exception.dart';
import '../../services/authentication/firebase_auth_session.dart';
import '../../services/crash_reporting/crash_reporter.dart';
import '../../services/crash_reporting/firebase_crash_reporter.dart';
import '../../services/device_management/device_management_service.dart';
import '../../services/device_management/models/brine_device.dart';
import '../../services/push_notifications/push_notifications_service.dart';
import '../errors/error_route.dart';
import '../errors/models/error_type.dart';
import '../softener_monitor/softener_monitor_route.dart';
import '../welcome/welcome_route.dart';

part 'setup_controller.dart';
part 'setup_view.dart';

/// Performs the setup necessary to proceed to the next route. This involves getting a list of the user's devices,
/// assuming any have been added to the user's account, getting the details for each device, and handling errors related
/// to these processes.
///
/// Dependencies can be injected for testing. When no overrides are provided, the route uses production implementations
/// that delegate to Firebase.
class SetupRoute extends StatefulWidget {
  /// Creates an instance of [SetupRoute].
  ///
  /// All parameters are optional. When omitted, production implementations are used.
  const SetupRoute({
    this.authSession = const FirebaseAuthSession(),
    this.crashReporter = const FirebaseCrashReporter(),
    this.deviceManagementServiceFactory,
    this.pushNotificationsServiceFactory,
    super.key,
  });

  /// Provides access to the current authenticated user.
  ///
  /// Defaults to [FirebaseAuthSession], which delegates to `FirebaseAuth.instance`.
  final AuthSession authSession;

  /// Reports non-fatal errors for analysis.
  ///
  /// Defaults to [FirebaseCrashReporter], which delegates to `FirebaseCrashlytics.instance`.
  final CrashReporter crashReporter;

  /// An optional factory for creating a [DeviceManagementService] given a [User].
  ///
  /// When null, the controller creates a standard [DeviceManagementService] instance. Providing a factory in tests
  /// allows substitution with a mock or fake service.
  final DeviceManagementService Function(User user)? deviceManagementServiceFactory;

  /// An optional factory for creating a [PushNotificationsService] given a [User].
  ///
  /// When null, the controller creates a standard [PushNotificationsService] instance. Providing a factory in tests
  /// allows substitution with a mock or fake service.
  final PushNotificationsService Function(User user)? pushNotificationsServiceFactory;

  @override
  State<SetupRoute> createState() => SetupController();
}
