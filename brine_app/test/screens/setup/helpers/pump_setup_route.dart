import 'package:brine/l10n/app_localizations.dart';
import 'package:brine/screens/setup/setup_route.dart';
import 'package:brine/services/authentication/auth_session.dart';
import 'package:brine/services/crash_reporting/crash_reporter.dart';
import 'package:brine/services/device_management/device_management_service.dart';
import 'package:brine/services/device_management/models/brine_device.dart';
import 'package:brine/services/push_notifications/push_notifications_service.dart';
import 'package:brine/theme/brine_app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'no_op_crash_reporter.dart';

/// Pumps the [SetupRoute] inside a fully configured [MaterialApp] with injected dependencies.
///
/// The [authSession] controls what user the controller sees. The [deviceManagementServiceFactory] controls what devices
/// are returned. Both are required so that tests explicitly declare the scenario being tested.
///
/// The [crashReporter] defaults to [NoOpCrashReporter] to avoid Firebase Crashlytics initialization in tests.
///
/// The [pushNotificationsServiceFactory] is optional and defaults to null (which causes the controller to skip FCM
/// registration on non-mobile platforms, which is the case in the test environment).
Future<void> pumpSetupRoute(
  WidgetTester tester, {
  required AuthSession authSession,
  required DeviceManagementService Function(User user) deviceManagementServiceFactory,
  CrashReporter crashReporter = const NoOpCrashReporter(),
  PushNotificationsService Function(User user)? pushNotificationsServiceFactory,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: BrineAppTheme.lightThemeData,
      darkTheme: BrineAppTheme.darkThemeData,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: SetupRoute(
        authSession: authSession,
        crashReporter: crashReporter,
        deviceManagementServiceFactory: deviceManagementServiceFactory,
        pushNotificationsServiceFactory: pushNotificationsServiceFactory,
      ),
    ),
  );
}

/// Creates a list of test [BrineDevice] instances for use in setup route tests.
List<BrineDevice> createTestDevices({int count = 1}) {
  return List.generate(
    count,
    (int index) => BrineDevice(
      deviceId: 'test_device_$index',
      name: 'dev$index',
      saltDistance: 150,
      applianceHeight: 300,
      saltLevel: 0.5,
      batteryLevel: 0.8,
      lastUpdatedTimestamp: DateTime(2025, 5, 1, 12),
      retrievalTimestamp: DateTime.now(),
    ),
  );
}
