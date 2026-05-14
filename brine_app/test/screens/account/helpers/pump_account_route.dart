import 'package:brine/l10n/app_localizations.dart';
import 'package:brine/screens/account/account_route.dart';
import 'package:brine/services/device_management/models/brine_device.dart';
import 'package:brine/theme/brine_app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps the [AccountRoute] inside a fully configured [MaterialApp] with localization delegates and the app's theme.
///
/// Because [AccountRoute] accesses `FirebaseAuth.instance.currentUser` in its controller, this helper is only usable in
/// tests where Firebase Auth has been properly mocked or where the test does not trigger code paths that access the
/// Firebase singleton.
Future<void> pumpAccountRoute(
  WidgetTester tester, {
  required List<BrineDevice> devices,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: BrineAppTheme.lightThemeData,
      darkTheme: BrineAppTheme.darkThemeData,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: AccountRoute(devices: devices),
    ),
  );

  await tester.pumpAndSettle();
}
