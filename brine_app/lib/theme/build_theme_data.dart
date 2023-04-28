import 'package:flutter/material.dart';

/// Default [TextTheme] used for both light and dark theme modes.
const TextTheme defaultTextTheme = TextTheme(
  bodyLarge: TextStyle(
    fontSize: 18,
  ),
);

/// Default light theme data.
final ThemeData lightThemeData = ThemeData(
  primaryColor: const Color(0xFFEDA200),
  useMaterial3: true,
  textTheme: defaultTextTheme,
);

/// Default dark theme data.
final ThemeData darkThemeData = ThemeData(
  primaryColor: const Color(0xFFEDA200),
  useMaterial3: true,
  textTheme: defaultTextTheme,
);
