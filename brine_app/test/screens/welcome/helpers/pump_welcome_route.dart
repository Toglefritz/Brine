import 'package:brine/l10n/app_localizations.dart';
import 'package:brine/screens/welcome/welcome_route.dart';
import 'package:brine/theme/brine_app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps the [WelcomeRoute] inside a fully configured [MaterialApp] with localization delegates and the app's theme.
///
/// This helper is shared across the welcome screen test files to avoid duplicating boilerplate setup.
Future<void> pumpWelcomeRoute(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: BrineAppTheme.lightThemeData,
      darkTheme: BrineAppTheme.darkThemeData,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const WelcomeRoute(),
    ),
  );

  // Allow the localizations and any async frame callbacks to settle.
  await tester.pumpAndSettle();
}
