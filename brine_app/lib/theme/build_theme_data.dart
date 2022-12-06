import 'package:flutter/material.dart';

/// Returns [ThemeData] for the app's light theme.
ThemeData buildLightThemeData() {
  return ThemeData(
    colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue),
    useMaterial3: true,
    brightness: Brightness.light,
  );
}

/// Returns [ThemeData] for the app's dark theme.
ThemeData buildDarkThemeData() {
  return ThemeData(
    colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue),
    useMaterial3: true,
    brightness: Brightness.dark,
  );
}
