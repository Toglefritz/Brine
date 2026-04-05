import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../../l10n/app_localizations.dart';
import '../../themes/dark_theme.dart';
import '../../themes/light_theme.dart';
import 'under_construction_route.dart';

/// A minimal [MaterialApp] that renders only the under construction page.
///
/// This exists so the under construction mode can boot without initializing Firebase or any other services on which the
/// full app depends. It uses the same theme definitions as the main app to keep the visual identity consistent.
class UnderConstructionApp extends StatelessWidget {
  /// Creates an instance of [UnderConstructionApp].
  const UnderConstructionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brine',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: LightTheme.lightTheme,
      darkTheme: DarkTheme.darkTheme,
      home: const UnderConstructionRoute(),
    );
  }
}
