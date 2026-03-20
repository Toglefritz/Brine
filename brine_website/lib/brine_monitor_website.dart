import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'router.dart';
import 'themes/dark_theme.dart';
import 'themes/dark_theme_provider.dart';
import 'themes/light_theme.dart';

/// Wraps the entire app and returns the root [MaterialApp] widget, along with its theme data.
class BrineMonitorWebsite extends StatefulWidget {
  /// Creates an instance of [BrineMonitorWebsite].
  const BrineMonitorWebsite({super.key});

  @override
  State<BrineMonitorWebsite> createState() => _BrineMonitorWebsiteState();
}

class _BrineMonitorWebsiteState extends State<BrineMonitorWebsite> {
  /// A [Provider] for the application's theme mode.
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  @override
  void initState() {
    super.initState();

    // Get the current darkTheme preference
    _getCurrentAppTheme();
  }

  /// Gets the current dark theme preference.
  Future<void> _getCurrentAppTheme() async {
    themeChangeProvider.darkTheme = await themeChangeProvider.darkThemePreference.getTheme();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        return themeChangeProvider;
      },
      child: Consumer<DarkThemeProvider>(
        builder: (BuildContext context, DarkThemeProvider darkThemeProvider, Widget? child) {
          return MaterialApp.router(
            title: 'Brine',
            debugShowCheckedModeBanner: false,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            themeMode: darkThemeProvider.darkTheme ? ThemeMode.dark : ThemeMode.light,
            theme: darkThemeProvider.darkTheme ? DarkTheme.darkTheme : LightTheme.lightTheme,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
