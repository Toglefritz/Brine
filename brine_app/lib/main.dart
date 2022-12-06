import 'package:brine/screens/softener_monitor/softener_monitor_route.dart';
import 'package:brine/theme/build_theme_data.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const BrineApp());
}

/// Loads the app theme and home page.
class BrineApp extends StatelessWidget {
  const BrineApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brine',
      themeMode: ThemeMode.system,
      theme: buildLightThemeData(),
      darkTheme: buildDarkThemeData(),
      home: const SoftenerMonitorRoute(),
    );
  }
}
