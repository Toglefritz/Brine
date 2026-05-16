import 'package:brine/l10n/app_localizations.dart';
import 'package:brine/screens/account/account_route.dart';
import 'package:brine/services/authentication/auth_session.dart';
import 'package:brine/services/device_management/device_management_service.dart';
import 'package:brine/services/device_management/models/brine_device.dart';
import 'package:brine/theme/brine_app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps the [AccountRoute] inside a fully configured [MaterialApp] with injected dependencies.
///
/// The [authSession] controls what user the controller sees. When provided, the route no longer accesses
/// `FirebaseAuth.instance` directly, allowing full widget testing without Firebase platform initialization.
Future<void> pumpAccountRoute(
  WidgetTester tester, {
  required List<BrineDevice> devices,
  required AuthSession authSession,
  DeviceManagementService Function(User user)? deviceManagementServiceFactory,
  Future<void> Function()? signOut,
  Future<void> Function(User user)? deleteUserDocument,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: BrineAppTheme.lightThemeData,
      darkTheme: BrineAppTheme.darkThemeData,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: AccountRoute(
        devices: devices,
        authSession: authSession,
        deviceManagementServiceFactory: deviceManagementServiceFactory,
        signOut: signOut,
        deleteUserDocument: deleteUserDocument,
      ),
    ),
  );

  await tester.pumpAndSettle();
}
