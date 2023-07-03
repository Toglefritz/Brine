import 'package:flutter/material.dart';

/// Default [TextTheme] used for both light and dark theme modes.
const TextTheme defaultTextTheme = TextTheme(
  bodyLarge: TextStyle(
    fontSize: 18,
  ),
);

/// Default light theme data.
final ThemeData lightThemeData = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFFEDA200),
  useMaterial3: true,
  scaffoldBackgroundColor: const Color(0xFFFFF0D1),
  textTheme: defaultTextTheme,
);

/// Default dark theme data.
final ThemeData darkThemeData = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFFEDA200),
  useMaterial3: true,
  textTheme: defaultTextTheme,
);
