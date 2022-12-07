import 'package:brine/screens/softener_monitor/softener_monitor_route.dart';
import 'package:brine/theme/build_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';

void main() {
  runApp(const BrineApp());
}

/// Loads the app theme and home page.
class BrineApp extends StatelessWidget {
  const BrineApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightColorScheme, darkColorScheme) {
        return MaterialApp(
          title: 'Brine',
          themeMode: ThemeMode.system,
          theme: ThemeData(
            colorScheme: lightColorScheme ?? defaultLightColorScheme,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: darkColorScheme ?? defaultDarkColorScheme,
            useMaterial3: true,
          ),
          home: const SoftenerMonitorRoute(),
        );
      },
    );
  }
}
