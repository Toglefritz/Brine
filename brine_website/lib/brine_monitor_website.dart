import 'package:brinemonitor/router.dart';
import 'package:brinemonitor/themes/dark_theme.dart';
import 'package:brinemonitor/themes/light_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Wraps the entire app and returns the root [MaterialApp] widget, along with its theme data.
class BrineMonitorWebsite extends StatelessWidget {
  const BrineMonitorWebsite({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'HerdGPT',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      themeMode: ThemeMode.light,
      theme: lightTheme,
      darkTheme: darkTheme,
      routerConfig: router,
    );
  }
}
