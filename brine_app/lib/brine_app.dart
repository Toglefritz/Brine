import 'package:brine/screens/authentication/onboarding/onboarding_route.dart';
import 'package:brine/theme/build_theme_data.dart';
import 'package:flutter/material.dart';

/// Loads the app theme and home page.
class BrineApp extends StatelessWidget {
  const BrineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brine',
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      theme: lightThemeData,
      darkTheme: darkThemeData,
      home: const OnboardingRoute(),
    );
  }
}
