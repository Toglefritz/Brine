import 'package:brinemonitor/router.dart';
import 'package:brinemonitor/themes/dark_theme.dart';
import 'package:brinemonitor/themes/dark_theme_provider.dart';
import 'package:brinemonitor/themes/light_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

/// Wraps the entire app and returns the root [MaterialApp] widget, along with its theme data.
class BrineMonitorWebsite extends StatefulWidget {
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
  void _getCurrentAppTheme() async {
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
            theme: darkThemeProvider.darkTheme ? darkTheme : lightTheme,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
